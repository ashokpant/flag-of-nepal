package flagofnepal;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * Author: Ashok Kumar Pant <asokpant@gmail.com>
 * Date: July 19, 2026
 */
public final class FlagOfNepal {

    private static final String CRIMSON = "#DC143C";
    private static final String DEEP_BLUE = "#003893";
    private static final String WHITE = "#FFFFFF";
    private static final String INK = "#111111";
    private static final String IMAGINARY = "#888888";
    private static final String[] MODES = {"color", "skeleton", "landmark"};

    private FlagOfNepal() {}

    static final class Pt {
        final double x, y;

        Pt(double x, double y) {
            this.x = x;
            this.y = y;
        }
    }

    static final class Edge {
        final Pt a, b;

        Edge(Pt a, Pt b) {
            this.a = a;
            this.b = b;
        }
    }

    static final class Arc {
        final Pt c;
        final double r, t0, dt;

        Arc(Pt c, double r, double t0, double dt) {
            this.c = c;
            this.r = r;
            this.t0 = t0;
            this.dt = dt;
        }
    }

    static final class Geom {
        final double baseLength, borderWidth;
        final Map<String, Pt> points = new LinkedHashMap<>();
        final List<Pt> border = new ArrayList<>();
        final List<Pt> inner = new ArrayList<>();
        final List<Pt> moon = new ArrayList<>();
        final List<Pt> sun = new ArrayList<>();
        final List<Edge> moonRays = new ArrayList<>();
        final List<Edge> sunRays = new ArrayList<>();
        final List<Edge> imaginary = new ArrayList<>();
        final Map<String, Arc> arcs = new LinkedHashMap<>();
        final Map<String, double[]> circles = new LinkedHashMap<>(); // cx,cy,r

        Geom(double baseLength, double borderWidth) {
            this.baseLength = baseLength;
            this.borderWidth = borderWidth;
        }

        double[] bounds() {
            double minX = Double.POSITIVE_INFINITY, minY = Double.POSITIVE_INFINITY;
            double maxX = Double.NEGATIVE_INFINITY, maxY = Double.NEGATIVE_INFINITY;
            for (List<Pt> poly : List.of(border, inner, moon, sun)) {
                for (Pt p : poly) {
                    minX = Math.min(minX, p.x);
                    minY = Math.min(minY, p.y);
                    maxX = Math.max(maxX, p.x);
                    maxY = Math.max(maxY, p.y);
                }
            }
            for (Pt p : points.values()) {
                minX = Math.min(minX, p.x);
                minY = Math.min(minY, p.y);
                maxX = Math.max(maxX, p.x);
                maxY = Math.max(maxY, p.y);
            }
            double pad = borderWidth > 0 ? borderWidth * 0.5 : baseLength * 0.02;
            return new double[] {minX - pad, minY - pad, maxX + pad, maxY + pad};
        }
    }

    private static double dist(Pt a, Pt b) {
        return Math.hypot(b.x - a.x, b.y - a.y);
    }

    private static Pt mid(Pt a, Pt b) {
        return new Pt((a.x + b.x) / 2, (a.y + b.y) / 2);
    }

    private static Pt[] parallelEdge(Pt a, Pt b, double d) {
        double dx = b.x - a.x, dy = b.y - a.y;
        double len = Math.hypot(dx, dy);
        double nx = dy / len, ny = -dx / len;
        return new Pt[] {
            new Pt(a.x + d * nx, a.y + d * ny),
            new Pt(b.x + d * nx, b.y + d * ny)
        };
    }

    private static Pt intersectLines(Pt p1, Pt d1, Pt p2, Pt d2) {
        double denom = d1.x * d2.y - d1.y * d2.x;
        double s = ((p2.x - p1.x) * d2.y - (p2.y - p1.y) * d2.x) / denom;
        return new Pt(p1.x + s * d1.x, p1.y + s * d1.y);
    }

    private static Pt intersectEdges(Pt a1, Pt a2, Pt b1, Pt b2) {
        return intersectLines(a1, new Pt(a2.x - a1.x, a2.y - a1.y),
                b1, new Pt(b2.x - b1.x, b2.y - b1.y));
    }

    private static Pt[] intersectLineCircle(Pt origin, Pt dir, Pt center, double radius) {
        double dpx = origin.x - center.x, dpy = origin.y - center.y;
        double a = dir.x * dir.x + dir.y * dir.y;
        double b = 2 * (dpx * dir.x + dpy * dir.y);
        double c = dpx * dpx + dpy * dpy - radius * radius;
        double delta = b * b - 4 * a * c;
        if (Math.abs(delta) < 1e-14) {
            delta = 0;
        }
        if (delta < 0) {
            return new Pt[0];
        }
        double sqrtD = Math.sqrt(delta);
        double u1 = (-b - sqrtD) / (2 * a);
        double u2 = (-b + sqrtD) / (2 * a);
        return new Pt[] {
            new Pt(origin.x + u1 * dir.x, origin.y + u1 * dir.y),
            new Pt(origin.x + u2 * dir.x, origin.y + u2 * dir.y)
        };
    }

    private static Pt[] intersectCircles(Pt c1, double r1, Pt c2, double r2) {
        double d = dist(c1, c2);
        double a = (r1 * r1 - r2 * r2 + d * d) / (2 * d);
        double h2 = r1 * r1 - a * a;
        if (Math.abs(h2) < 1e-12) {
            h2 = 0;
        }
        double h = Math.sqrt(h2);
        Pt mid = new Pt(c1.x + a / d * (c2.x - c1.x), c1.y + a / d * (c2.y - c1.y));
        double dx = c2.x - c1.x, dy = c2.y - c1.y;
        double rx = -dy * (h / d), ry = dx * (h / d);
        return new Pt[] {
            new Pt(mid.x + rx, mid.y + ry),
            new Pt(mid.x - rx, mid.y - ry)
        };
    }

    private static double distancePointEdge(Pt p, Pt a, Pt b) {
        double abx = b.x - a.x, aby = b.y - a.y;
        double t = ((p.x - a.x) * abx + (p.y - a.y) * aby) / (abx * abx + aby * aby);
        t = Math.max(0, Math.min(1, t));
        return dist(p, new Pt(a.x + t * abx, a.y + t * aby));
    }

    private static List<Pt> arcPolyline(Pt c, double r, double t0Deg, double dtDeg, int n) {
        List<Pt> pts = new ArrayList<>(n);
        double t0 = Math.toRadians(t0Deg);
        double t1 = t0 + Math.toRadians(dtDeg);
        for (int i = 0; i < n; i++) {
            double t = t0 + (t1 - t0) * i / (n - 1.0);
            pts.add(new Pt(c.x + r * Math.cos(t), c.y + r * Math.sin(t)));
        }
        return pts;
    }

    private static List<Pt> circlePolygon(Pt c, double r, int n) {
        List<Pt> pts = new ArrayList<>(n + 1);
        for (int i = 0; i <= n; i++) {
            double t = 2 * Math.PI * i / n;
            pts.add(new Pt(c.x + r * Math.cos(t), c.y + r * Math.sin(t)));
        }
        return pts;
    }

    static Geom construct(double b) {
        Pt A = new Pt(0, 0);
        Pt B = new Pt(b, 0);
        Pt C = new Pt(0, b + b / 3.0);
        Pt D = new Pt(0, b);

        Pt[] ePts = intersectLineCircle(B, new Pt(D.x - B.x, D.y - B.y), B, b);
        Pt E = ePts[1];
        Pt F = new Pt(0, E.y);
        Pt G = new Pt(b, E.y);

        Pt H = new Pt(b / 4.0, 0);
        Pt I = intersectEdges(H, new Pt(H.x, C.y), C, G);
        Pt J = mid(C, F);
        Pt K = intersectEdges(J, new Pt(J.x + b, J.y), C, G);
        Pt L = intersectEdges(J, K, H, I);
        Pt M = intersectEdges(J, G, H, I);
        Pt N = new Pt(M.x, M.y - distancePointEdge(M, B, D));
        Pt O = new Pt(A.x, M.y);
        Pt O1 = intersectEdges(O, M, C, G);

        double radiusL = dist(L, N);
        Pt[] pq = intersectLineCircle(O, new Pt(M.x - O.x, M.y - O.y), L, radiusL);
        Pt P = pq[0], Q = pq[1];
        double radiusM = dist(M, Q);
        double radiusN = dist(N, M);
        Pt[] rs = intersectCircles(L, radiusL, N, radiusN);
        Pt R = rs[0].x <= rs[1].x ? rs[0] : rs[1];
        Pt S = rs[0].x <= rs[1].x ? rs[1] : rs[0];
        Pt T = intersectEdges(R, S, H, I);
        double radiusTU = dist(T, S);
        double radiusTL = dist(T, M);

        List<Pt> xu = arcPolyline(T, radiusTU, 180, -180, 38);
        List<Pt> xl = arcPolyline(T, radiusTL, 195, -210, 11);

        Pt U = mid(A, F);
        Pt V = intersectEdges(U, new Pt(U.x + b, U.y), B, E);
        Pt W = intersectEdges(U, V, H, I);

        double radiusWI = dist(M, N);
        double radiusWO = dist(L, N);
        List<Pt> pi = circlePolygon(W, radiusWI, 24);
        List<Pt> po = circlePolygon(W, radiusWO, 48);

        double borderWidth = dist(T, N);
        Geom g = new Geom(b, borderWidth);

        g.points.put("A", A); g.points.put("B", B); g.points.put("C", C);
        g.points.put("D", D); g.points.put("E", E); g.points.put("F", F);
        g.points.put("G", G); g.points.put("H", H); g.points.put("I", I);
        g.points.put("J", J); g.points.put("K", K); g.points.put("L", L);
        g.points.put("M", M); g.points.put("N", N); g.points.put("O", O);
        g.points.put("O1", O1); g.points.put("P", P); g.points.put("Q", Q);
        g.points.put("R", R); g.points.put("S", S); g.points.put("T", T);
        g.points.put("U", U); g.points.put("V", V); g.points.put("W", W);

        g.inner.addAll(List.of(A, B, E, G, C));

        Pt[] abB = parallelEdge(A, B, borderWidth);
        Pt[] acB = parallelEdge(A, C, -borderWidth);
        Pt[] cgB = parallelEdge(C, G, -borderWidth);
        Pt[] egB = parallelEdge(E, G, borderWidth);
        Pt[] beB = parallelEdge(B, E, borderWidth);
        Pt aBi = intersectLines(abB[0], new Pt(abB[1].x - abB[0].x, abB[1].y - abB[0].y),
                acB[0], new Pt(acB[1].x - acB[0].x, acB[1].y - acB[0].y));
        Pt cBi = intersectLines(acB[0], new Pt(acB[1].x - acB[0].x, acB[1].y - acB[0].y),
                cgB[0], new Pt(cgB[1].x - cgB[0].x, cgB[1].y - cgB[0].y));
        Pt gBi = intersectLines(cgB[0], new Pt(cgB[1].x - cgB[0].x, cgB[1].y - cgB[0].y),
                egB[0], new Pt(egB[1].x - egB[0].x, egB[1].y - egB[0].y));
        Pt eBi = intersectLines(egB[0], new Pt(egB[1].x - egB[0].x, egB[1].y - egB[0].y),
                beB[0], new Pt(beB[1].x - beB[0].x, beB[1].y - beB[0].y));
        Pt bBi = intersectLines(abB[0], new Pt(abB[1].x - abB[0].x, abB[1].y - abB[0].y),
                beB[0], new Pt(beB[1].x - beB[0].x, beB[1].y - beB[0].y));
        g.border.addAll(List.of(aBi, bBi, eBi, gBi, cBi));

        addMoonRays(g, xu, xl);

        int[] sunOrder = {1, 4, 3, 8, 5, 12, 7, 16, 9, 20, 11, 24, 13, 28, 15, 32, 17, 36, 19, 40, 21, 44, 23, 0};
        for (int i = 0; i < sunOrder.length; i += 2) {
            g.sun.add(pi.get(sunOrder[i]));
            g.sun.add(po.get(sunOrder[i + 1]));
        }

        addSunRays(g, pi, po);

        List<Pt> arcPqu = arcPolyline(L, radiusL, -159, 138, 65);
        List<Pt> arcPql = arcPolyline(M, radiusM, -180, 180, 65);
        List<Pt> crispL = List.of(
                xu.get(0), xl.get(1), xu.get(4), xl.get(2), xu.get(8), xl.get(3),
                xu.get(12), xl.get(4), xu.get(16), xl.get(5));
        List<Pt> crispR = List.of(
                xu.get(xu.size() - 1), xl.get(xl.size() - 2), xu.get(xu.size() - 5),
                xl.get(xl.size() - 3), xu.get(xu.size() - 9), xl.get(xl.size() - 4),
                xu.get(xu.size() - 13), xl.get(xl.size() - 5), xu.get(xu.size() - 17),
                xl.get(xl.size() - 6));
        for (Pt p : arcPqu) {
            if (p.x <= R.x) {
                g.moon.add(p);
            }
        }
        g.moon.addAll(crispL);
        for (int i = crispR.size() - 1; i >= 0; i--) {
            g.moon.add(crispR.get(i));
        }
        for (Pt p : arcPqu) {
            if (p.x >= S.x) {
                g.moon.add(p);
            }
        }
        for (int i = arcPql.size() - 1; i >= 0; i--) {
            g.moon.add(arcPql.get(i));
        }

        g.arcs.put("crescent_outer", new Arc(L, radiusL, -159, 138));
        g.arcs.put("crescent_inner", new Arc(M, radiusM, -180, 180));
        g.arcs.put("moon_upper", new Arc(T, radiusTU, 180, -180));
        g.arcs.put("moon_lower", new Arc(T, radiusTL, 195, -210));
        g.arcs.put("n_arc", new Arc(N, radiusN, 180, -180));
        g.circles.put("sun_inner", new double[] {W.x, W.y, radiusWI});
        g.circles.put("sun_outer", new double[] {W.x, W.y, radiusWO});

        g.imaginary.add(new Edge(H, I));
        g.imaginary.add(new Edge(J, K));
        g.imaginary.add(new Edge(J, G));
        g.imaginary.add(new Edge(O, O1));
        g.imaginary.add(new Edge(R, S));
        g.imaginary.add(new Edge(F, G));
        g.imaginary.add(new Edge(U, V));
        g.imaginary.add(new Edge(B, D));

        return g;
    }

    private static void addMoonRays(Geom g, List<Pt> xu, List<Pt> xl) {
        int n = xu.size(), m = xl.size();
        g.moonRays.add(new Edge(xu.get(0), xl.get(1)));
        g.moonRays.add(new Edge(xu.get(n - 1), xl.get(m - 2)));
        g.moonRays.add(new Edge(xl.get(1), xu.get(4)));
        g.moonRays.add(new Edge(xu.get(4), xl.get(2)));
        g.moonRays.add(new Edge(xl.get(m - 2), xu.get(n - 5)));
        g.moonRays.add(new Edge(xu.get(n - 5), xl.get(m - 3)));
        g.moonRays.add(new Edge(xl.get(2), xu.get(8)));
        g.moonRays.add(new Edge(xu.get(8), xl.get(3)));
        g.moonRays.add(new Edge(xl.get(m - 3), xu.get(n - 9)));
        g.moonRays.add(new Edge(xu.get(n - 9), xl.get(m - 4)));
        g.moonRays.add(new Edge(xl.get(3), xu.get(12)));
        g.moonRays.add(new Edge(xu.get(12), xl.get(4)));
        g.moonRays.add(new Edge(xl.get(m - 4), xu.get(n - 13)));
        g.moonRays.add(new Edge(xu.get(n - 13), xl.get(m - 5)));
        g.moonRays.add(new Edge(xl.get(4), xu.get(16)));
        g.moonRays.add(new Edge(xu.get(16), xl.get(5)));
        g.moonRays.add(new Edge(xl.get(m - 5), xu.get(n - 17)));
        g.moonRays.add(new Edge(xu.get(n - 17), xl.get(m - 6)));
    }

    private static void addSunRays(Geom g, List<Pt> pi, List<Pt> po) {
        g.sunRays.add(new Edge(pi.get(1), po.get(0)));
        g.sunRays.add(new Edge(pi.get(1), po.get(4)));
        g.sunRays.add(new Edge(po.get(4), pi.get(3)));
        g.sunRays.add(new Edge(pi.get(3), po.get(8)));
        g.sunRays.add(new Edge(po.get(8), pi.get(5)));
        g.sunRays.add(new Edge(pi.get(5), po.get(12)));
        g.sunRays.add(new Edge(po.get(12), pi.get(7)));
        g.sunRays.add(new Edge(pi.get(7), po.get(16)));
        g.sunRays.add(new Edge(po.get(16), pi.get(9)));
        g.sunRays.add(new Edge(pi.get(9), po.get(20)));
        g.sunRays.add(new Edge(po.get(20), pi.get(11)));
        g.sunRays.add(new Edge(pi.get(11), po.get(24)));
        g.sunRays.add(new Edge(po.get(24), pi.get(13)));
        g.sunRays.add(new Edge(pi.get(13), po.get(28)));
        g.sunRays.add(new Edge(po.get(28), pi.get(15)));
        g.sunRays.add(new Edge(pi.get(15), po.get(32)));
        g.sunRays.add(new Edge(po.get(32), pi.get(17)));
        g.sunRays.add(new Edge(pi.get(17), po.get(36)));
        g.sunRays.add(new Edge(po.get(36), pi.get(19)));
        g.sunRays.add(new Edge(pi.get(19), po.get(40)));
        g.sunRays.add(new Edge(po.get(40), pi.get(21)));
        g.sunRays.add(new Edge(pi.get(21), po.get(44)));
        g.sunRays.add(new Edge(po.get(44), pi.get(23)));
        g.sunRays.add(new Edge(pi.get(23), po.get(0)));
    }

    private static String fmt(double v) {
        return String.format(Locale.US, "%.4f", v);
    }

    private static String polyPoints(List<Pt> pts, double flip) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < pts.size(); i++) {
            if (i > 0) {
                sb.append(' ');
            }
            Pt p = pts.get(i);
            sb.append(fmt(p.x)).append(',').append(fmt(flip - p.y));
        }
        return sb.toString();
    }

    private static void edge(StringBuilder sb, Pt a, Pt b, double flip, String color, double width, String dash) {
        sb.append("<line x1=\"").append(fmt(a.x)).append("\" y1=\"").append(fmt(flip - a.y))
                .append("\" x2=\"").append(fmt(b.x)).append("\" y2=\"").append(fmt(flip - b.y))
                .append("\" stroke=\"").append(color).append("\" stroke-width=\"").append(width).append('"');
        if (dash != null) {
            sb.append(" stroke-dasharray=\"").append(dash).append('"');
        }
        sb.append(" />\n");
    }

    private static void arcPath(StringBuilder sb, Arc arc, double flip, String color, double width, String dash) {
        List<Pt> pts = arcPolyline(arc.c, arc.r, arc.t0, arc.dt, 64);
        sb.append("<path d=\"M ").append(fmt(pts.get(0).x)).append(',').append(fmt(flip - pts.get(0).y));
        for (int i = 1; i < pts.size(); i++) {
            sb.append(" L ").append(fmt(pts.get(i).x)).append(',').append(fmt(flip - pts.get(i).y));
        }
        sb.append("\" fill=\"none\" stroke=\"").append(color).append("\" stroke-width=\"").append(width).append('"');
        if (dash != null) {
            sb.append(" stroke-dasharray=\"").append(dash).append('"');
        }
        sb.append(" />\n");
    }

    static String toSvg(Geom g, String mode) {
        double[] b = g.bounds();
        double minX = b[0], maxX = b[2], maxY = b[3];
        double width = maxX - minX, height = maxY - b[1];
        double flip = maxY;

        StringBuilder sb = new StringBuilder();
        sb.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
        sb.append("<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"")
                .append(fmt(minX)).append(" 0 ").append(fmt(width)).append(' ').append(fmt(height))
                .append("\" width=\"").append(Math.round(width)).append("\" height=\"").append(Math.round(height))
                .append("\" role=\"img\" aria-label=\"National Flag of Nepal\">\n");
        sb.append("<title>National Flag of Nepal (").append(mode).append(")</title>\n");

        if ("color".equals(mode)) {
            List<Pt> border = new ArrayList<>(g.border);
            border.add(g.border.get(0));
            List<Pt> inner = new ArrayList<>(g.inner);
            inner.add(g.inner.get(0));
            List<Pt> sun = new ArrayList<>(g.sun);
            sun.add(g.sun.get(0));
            sb.append("<polygon points=\"").append(polyPoints(border, flip))
                    .append("\" fill=\"").append(DEEP_BLUE).append("\" stroke=\"none\" />\n");
            sb.append("<polygon points=\"").append(polyPoints(inner, flip))
                    .append("\" fill=\"").append(CRIMSON).append("\" stroke=\"none\" />\n");
            sb.append("<polygon points=\"").append(polyPoints(g.moon, flip))
                    .append("\" fill=\"").append(WHITE).append("\" stroke=\"none\" />\n");
            sb.append("<polygon points=\"").append(polyPoints(sun, flip))
                    .append("\" fill=\"").append(WHITE).append("\" stroke=\"none\" />\n");
        } else {
            Map<String, Pt> p = g.points;
            edge(sb, p.get("A"), p.get("B"), flip, INK, 1.5, null);
            edge(sb, p.get("A"), p.get("C"), flip, INK, 1.5, null);
            edge(sb, p.get("E"), p.get("G"), flip, INK, 1.5, null);
            edge(sb, p.get("C"), p.get("G"), flip, INK, 1.5, null);
            edge(sb, p.get("B"), p.get("E"), flip, INK, 1.5, null);
            for (int i = 0; i < g.border.size(); i++) {
                edge(sb, g.border.get(i), g.border.get((i + 1) % g.border.size()), flip, INK, 1.5, null);
            }
            for (String key : List.of("crescent_outer", "crescent_inner", "moon_lower")) {
                arcPath(sb, g.arcs.get(key), flip, INK, 1.5, null);
            }
            for (Edge e : g.moonRays) {
                edge(sb, e.a, e.b, flip, INK, 1.5, null);
            }
            for (Edge e : g.sunRays) {
                edge(sb, e.a, e.b, flip, INK, 1.5, null);
            }
            double[] ci = g.circles.get("sun_inner");
            sb.append("<circle cx=\"").append(fmt(ci[0])).append("\" cy=\"").append(fmt(flip - ci[1]))
                    .append("\" r=\"").append(fmt(ci[2]))
                    .append("\" fill=\"none\" stroke=\"").append(INK).append("\" stroke-width=\"1.5\" />\n");

            if ("landmark".equals(mode)) {
                double fs = g.baseLength * 0.035;
                for (Map.Entry<String, Pt> e : g.points.entrySet()) {
                    if ("O1".equals(e.getKey())) {
                        continue;
                    }
                    Pt pt = e.getValue();
                    sb.append("<circle cx=\"").append(fmt(pt.x)).append("\" cy=\"").append(fmt(flip - pt.y))
                            .append("\" r=\"3\" fill=\"").append(INK).append("\" />\n");
                    sb.append("<text x=\"").append(fmt(pt.x + 6)).append("\" y=\"").append(fmt(flip - pt.y - 6))
                            .append("\" font-family=\"Helvetica, Arial, sans-serif\" font-size=\"")
                            .append(String.format(Locale.US, "%.1f", fs)).append("\" fill=\"").append(INK)
                            .append("\">").append(e.getKey()).append("</text>\n");
                }
                arcPath(sb, g.arcs.get("moon_upper"), flip, IMAGINARY, 1, "6 4");
                arcPath(sb, g.arcs.get("n_arc"), flip, IMAGINARY, 1, "6 4");
                double[] co = g.circles.get("sun_outer");
                sb.append("<circle cx=\"").append(fmt(co[0])).append("\" cy=\"").append(fmt(flip - co[1]))
                        .append("\" r=\"").append(fmt(co[2]))
                        .append("\" fill=\"none\" stroke=\"").append(IMAGINARY)
                        .append("\" stroke-width=\"1\" stroke-dasharray=\"6 4\" />\n");
                for (Edge e : g.imaginary) {
                    edge(sb, e.a, e.b, flip, IMAGINARY, 1, "6 4");
                }
            }
        }
        sb.append("</svg>\n");
        return sb.toString();
    }

    static String toHtml(Geom g) {
        String[] titles = {"Colour flag", "Skeleton", "Landmarks"};
        StringBuilder body = new StringBuilder();
        for (int i = 0; i < MODES.length; i++) {
            String svg = toSvg(g, MODES[i]);
            if (svg.startsWith("<?xml")) {
                svg = svg.substring(svg.indexOf('\n') + 1);
            }
            body.append("    <section class=\"flag\">\n      <h2>").append(titles[i])
                    .append("</h2>\n")
                    .append(svg).append("    </section>\n\n");
        }
        return "<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n"
                + "  <meta charset=\"utf-8\" />\n"
                + "  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\" />\n"
                + "  <title>National Flag of Nepal</title>\n"
                + "  <style>\n"
                + "    body { margin: 0; font-family: Georgia, serif; background: #f6f4f1; color: #1a1a1a; }\n"
                + "    main { max-width: 900px; margin: 2rem auto; padding: 0 1.25rem 3rem; }\n"
                + "    h1 { font-weight: 400; }\n"
                + "    .meta { color: #555; margin: 0 0 2rem; }\n"
                + "    .flag { background: #fff; padding: 1.25rem 1.5rem 1.75rem; margin-bottom: 1.5rem; }\n"
                + "    .flag h2 { font-weight: 400; font-size: 1.15rem; margin: 0 0 1rem; }\n"
                + "    .flag svg { width: 100%; height: auto; display: block; }\n"
                + "  </style>\n</head>\n<body>\n  <main>\n"
                + "    <h1>National Flag of Nepal</h1>\n"
                + "    <p class=\"meta\">Base length AB = " + String.format(Locale.US, "%.0f", g.baseLength)
                + " · Border width TN = " + String.format(Locale.US, "%.4f", g.borderWidth)
                + " · Constitution of Nepal, Schedule 1, Article 8</p>\n"
                + body
                + "  </main>\n</body>\n</html>\n";
    }


    public static void main(String[] args) throws IOException {
        double base = args.length > 0 ? Double.parseDouble(args[0]) : 800.0;
        Path outDir = Path.of(args.length > 1 ? args[1] : "output");
        Files.createDirectories(outDir);

        Geom g = construct(base);
        for (String mode : MODES) {
            Path svg = outDir.resolve("np_flag_" + mode + ".svg");
            Files.writeString(svg, toSvg(g, mode), StandardCharsets.UTF_8);
            System.out.println(svg);
        }
        Path html = outDir.resolve("np_flag.html");
        Files.writeString(html, toHtml(g), StandardCharsets.UTF_8);
        System.out.println(html);
    }
}
