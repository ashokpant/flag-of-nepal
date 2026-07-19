// National Flag of Nepal — constitutional geometry (Schedule 1, Article 8).
// Author: Ashok Pant <asokpant@gmail.com>
// Date: July 19, 2026
// Uses:
//	cargo run -- [baseLength] [outputDir]

use std::collections::BTreeMap;
use std::env;
use std::fs;
use std::path::Path;
use std::process;

const CRIMSON: &str = "#DC143C";
const DEEP_BLUE: &str = "#003893";
const WHITE: &str = "#FFFFFF";
const INK: &str = "#111111";
const IMAGINARY: &str = "#888888";
const MODES: [&str; 3] = ["color", "skeleton", "landmark"];

#[derive(Clone, Copy)]
struct Pt {
    x: f64,
    y: f64,
}

#[derive(Clone, Copy)]
struct Edge {
    a: Pt,
    b: Pt,
}

#[derive(Clone, Copy)]
struct Arc {
    c: Pt,
    r: f64,
    t0: f64,
    dt: f64,
}

struct Geom {
    base_length: f64,
    border_width: f64,
    points: BTreeMap<&'static str, Pt>,
    border: Vec<Pt>,
    inner: Vec<Pt>,
    moon: Vec<Pt>,
    sun: Vec<Pt>,
    moon_rays: Vec<Edge>,
    sun_rays: Vec<Edge>,
    imaginary: Vec<Edge>,
    arcs: BTreeMap<&'static str, Arc>,
    circles: BTreeMap<&'static str, [f64; 3]>,
}

impl Geom {
    fn bounds(&self) -> (f64, f64, f64, f64) {
        let mut min_x = f64::INFINITY;
        let mut min_y = f64::INFINITY;
        let mut max_x = f64::NEG_INFINITY;
        let mut max_y = f64::NEG_INFINITY;
        let mut expand = |p: Pt| {
            min_x = min_x.min(p.x);
            min_y = min_y.min(p.y);
            max_x = max_x.max(p.x);
            max_y = max_y.max(p.y);
        };
        for poly in [&self.border, &self.inner, &self.moon, &self.sun] {
            for &p in poly {
                expand(p);
            }
        }
        for &p in self.points.values() {
            expand(p);
        }
        let pad = if self.border_width > 0.0 {
            self.border_width * 0.5
        } else {
            self.base_length * 0.02
        };
        (min_x - pad, min_y - pad, max_x + pad, max_y + pad)
    }
}

fn dist(a: Pt, b: Pt) -> f64 {
    (b.x - a.x).hypot(b.y - a.y)
}

fn mid(a: Pt, b: Pt) -> Pt {
    Pt {
        x: (a.x + b.x) / 2.0,
        y: (a.y + b.y) / 2.0,
    }
}

fn parallel_edge(a: Pt, b: Pt, d: f64) -> (Pt, Pt) {
    let dx = b.x - a.x;
    let dy = b.y - a.y;
    let len = dx.hypot(dy);
    let nx = dy / len;
    let ny = -dx / len;
    (
        Pt {
            x: a.x + d * nx,
            y: a.y + d * ny,
        },
        Pt {
            x: b.x + d * nx,
            y: b.y + d * ny,
        },
    )
}

fn intersect_lines(p1: Pt, d1: Pt, p2: Pt, d2: Pt) -> Pt {
    let denom = d1.x * d2.y - d1.y * d2.x;
    let s = ((p2.x - p1.x) * d2.y - (p2.y - p1.y) * d2.x) / denom;
    Pt {
        x: p1.x + s * d1.x,
        y: p1.y + s * d1.y,
    }
}

fn intersect_edges(a1: Pt, a2: Pt, b1: Pt, b2: Pt) -> Pt {
    intersect_lines(
        a1,
        Pt {
            x: a2.x - a1.x,
            y: a2.y - a1.y,
        },
        b1,
        Pt {
            x: b2.x - b1.x,
            y: b2.y - b1.y,
        },
    )
}

fn intersect_line_circle(origin: Pt, dir: Pt, center: Pt, radius: f64) -> Vec<Pt> {
    let dpx = origin.x - center.x;
    let dpy = origin.y - center.y;
    let a = dir.x * dir.x + dir.y * dir.y;
    let b = 2.0 * (dpx * dir.x + dpy * dir.y);
    let c = dpx * dpx + dpy * dpy - radius * radius;
    let mut delta = b * b - 4.0 * a * c;
    if delta.abs() < 1e-14 {
        delta = 0.0;
    }
    if delta < 0.0 {
        return Vec::new();
    }
    let sqrt_d = delta.sqrt();
    let u1 = (-b - sqrt_d) / (2.0 * a);
    let u2 = (-b + sqrt_d) / (2.0 * a);
    vec![
        Pt {
            x: origin.x + u1 * dir.x,
            y: origin.y + u1 * dir.y,
        },
        Pt {
            x: origin.x + u2 * dir.x,
            y: origin.y + u2 * dir.y,
        },
    ]
}

fn intersect_circles(c1: Pt, r1: f64, c2: Pt, r2: f64) -> Vec<Pt> {
    let d = dist(c1, c2);
    let a = (r1 * r1 - r2 * r2 + d * d) / (2.0 * d);
    let mut h2 = r1 * r1 - a * a;
    if h2.abs() < 1e-12 {
        h2 = 0.0;
    }
    let h = h2.sqrt();
    let mid = Pt {
        x: c1.x + a / d * (c2.x - c1.x),
        y: c1.y + a / d * (c2.y - c1.y),
    };
    let dx = c2.x - c1.x;
    let dy = c2.y - c1.y;
    let rx = -dy * (h / d);
    let ry = dx * (h / d);
    vec![
        Pt {
            x: mid.x + rx,
            y: mid.y + ry,
        },
        Pt {
            x: mid.x - rx,
            y: mid.y - ry,
        },
    ]
}

fn distance_point_edge(p: Pt, a: Pt, b: Pt) -> f64 {
    let abx = b.x - a.x;
    let aby = b.y - a.y;
    let mut t = ((p.x - a.x) * abx + (p.y - a.y) * aby) / (abx * abx + aby * aby);
    t = t.clamp(0.0, 1.0);
    dist(
        p,
        Pt {
            x: a.x + t * abx,
            y: a.y + t * aby,
        },
    )
}

fn arc_polyline(c: Pt, r: f64, t0_deg: f64, dt_deg: f64, n: usize) -> Vec<Pt> {
    let t0 = t0_deg.to_radians();
    let t1 = t0 + dt_deg.to_radians();
    (0..n)
        .map(|i| {
            let t = t0 + (t1 - t0) * i as f64 / (n - 1) as f64;
            Pt {
                x: c.x + r * t.cos(),
                y: c.y + r * t.sin(),
            }
        })
        .collect()
}

fn circle_polygon(c: Pt, r: f64, n: usize) -> Vec<Pt> {
    (0..=n)
        .map(|i| {
            let t = 2.0 * std::f64::consts::PI * i as f64 / n as f64;
            Pt {
                x: c.x + r * t.cos(),
                y: c.y + r * t.sin(),
            }
        })
        .collect()
}

fn construct(b: f64) -> Geom {
    let a = Pt { x: 0.0, y: 0.0 };
    let bb = Pt { x: b, y: 0.0 };
    let c = Pt {
        x: 0.0,
        y: b + b / 3.0,
    };
    let d = Pt { x: 0.0, y: b };

    let e_pts = intersect_line_circle(
        bb,
        Pt {
            x: d.x - bb.x,
            y: d.y - bb.y,
        },
        bb,
        b,
    );
    let e = e_pts[1];
    let f = Pt { x: 0.0, y: e.y };
    let g = Pt { x: b, y: e.y };

    let h = Pt { x: b / 4.0, y: 0.0 };
    let i = intersect_edges(h, Pt { x: h.x, y: c.y }, c, g);
    let j = mid(c, f);
    let k = intersect_edges(j, Pt { x: j.x + b, y: j.y }, c, g);
    let l = intersect_edges(j, k, h, i);
    let m = intersect_edges(j, g, h, i);
    let n = Pt {
        x: m.x,
        y: m.y - distance_point_edge(m, bb, d),
    };
    let o = Pt { x: a.x, y: m.y };
    let o1 = intersect_edges(o, m, c, g);

    let radius_l = dist(l, n);
    let pq = intersect_line_circle(
        o,
        Pt {
            x: m.x - o.x,
            y: m.y - o.y,
        },
        l,
        radius_l,
    );
    let (p, q) = (pq[0], pq[1]);
    let radius_m = dist(m, q);
    let radius_n = dist(n, m);
    let rs = intersect_circles(l, radius_l, n, radius_n);
    let (r, s) = if rs[0].x <= rs[1].x {
        (rs[0], rs[1])
    } else {
        (rs[1], rs[0])
    };
    let t = intersect_edges(r, s, h, i);
    let radius_tu = dist(t, s);
    let radius_tl = dist(t, m);

    let xu = arc_polyline(t, radius_tu, 180.0, -180.0, 38);
    let xl = arc_polyline(t, radius_tl, 195.0, -210.0, 11);

    let u = mid(a, f);
    let v = intersect_edges(u, Pt { x: u.x + b, y: u.y }, bb, e);
    let w = intersect_edges(u, v, h, i);

    let radius_wi = dist(m, n);
    let radius_wo = dist(l, n);
    let pi = circle_polygon(w, radius_wi, 24);
    let po = circle_polygon(w, radius_wo, 48);

    let border_width = dist(t, n);

    let (ab0, ab1) = parallel_edge(a, bb, border_width);
    let (ac0, ac1) = parallel_edge(a, c, -border_width);
    let (cg0, cg1) = parallel_edge(c, g, -border_width);
    let (eg0, eg1) = parallel_edge(e, g, border_width);
    let (be0, be1) = parallel_edge(bb, e, border_width);

    let a_bi = intersect_lines(
        ab0,
        Pt {
            x: ab1.x - ab0.x,
            y: ab1.y - ab0.y,
        },
        ac0,
        Pt {
            x: ac1.x - ac0.x,
            y: ac1.y - ac0.y,
        },
    );
    let c_bi = intersect_lines(
        ac0,
        Pt {
            x: ac1.x - ac0.x,
            y: ac1.y - ac0.y,
        },
        cg0,
        Pt {
            x: cg1.x - cg0.x,
            y: cg1.y - cg0.y,
        },
    );
    let g_bi = intersect_lines(
        cg0,
        Pt {
            x: cg1.x - cg0.x,
            y: cg1.y - cg0.y,
        },
        eg0,
        Pt {
            x: eg1.x - eg0.x,
            y: eg1.y - eg0.y,
        },
    );
    let e_bi = intersect_lines(
        eg0,
        Pt {
            x: eg1.x - eg0.x,
            y: eg1.y - eg0.y,
        },
        be0,
        Pt {
            x: be1.x - be0.x,
            y: be1.y - be0.y,
        },
    );
    let b_bi = intersect_lines(
        ab0,
        Pt {
            x: ab1.x - ab0.x,
            y: ab1.y - ab0.y,
        },
        be0,
        Pt {
            x: be1.x - be0.x,
            y: be1.y - be0.y,
        },
    );

    let xn = xu.len();
    let xm = xl.len();
    let moon_rays = vec![
        Edge { a: xu[0], b: xl[1] },
        Edge {
            a: xu[xn - 1],
            b: xl[xm - 2],
        },
        Edge { a: xl[1], b: xu[4] },
        Edge { a: xu[4], b: xl[2] },
        Edge {
            a: xl[xm - 2],
            b: xu[xn - 5],
        },
        Edge {
            a: xu[xn - 5],
            b: xl[xm - 3],
        },
        Edge { a: xl[2], b: xu[8] },
        Edge { a: xu[8], b: xl[3] },
        Edge {
            a: xl[xm - 3],
            b: xu[xn - 9],
        },
        Edge {
            a: xu[xn - 9],
            b: xl[xm - 4],
        },
        Edge {
            a: xl[3],
            b: xu[12],
        },
        Edge {
            a: xu[12],
            b: xl[4],
        },
        Edge {
            a: xl[xm - 4],
            b: xu[xn - 13],
        },
        Edge {
            a: xu[xn - 13],
            b: xl[xm - 5],
        },
        Edge {
            a: xl[4],
            b: xu[16],
        },
        Edge {
            a: xu[16],
            b: xl[5],
        },
        Edge {
            a: xl[xm - 5],
            b: xu[xn - 17],
        },
        Edge {
            a: xu[xn - 17],
            b: xl[xm - 6],
        },
    ];

    let sun_order = [
        1, 4, 3, 8, 5, 12, 7, 16, 9, 20, 11, 24, 13, 28, 15, 32, 17, 36, 19, 40, 21, 44, 23, 0,
    ];
    let mut sun = Vec::new();
    for chunk in sun_order.chunks(2) {
        sun.push(pi[chunk[0]]);
        sun.push(po[chunk[1]]);
    }

    let sun_rays = vec![
        Edge { a: pi[1], b: po[0] },
        Edge { a: pi[1], b: po[4] },
        Edge { a: po[4], b: pi[3] },
        Edge { a: pi[3], b: po[8] },
        Edge { a: po[8], b: pi[5] },
        Edge { a: pi[5], b: po[12] },
        Edge { a: po[12], b: pi[7] },
        Edge { a: pi[7], b: po[16] },
        Edge { a: po[16], b: pi[9] },
        Edge { a: pi[9], b: po[20] },
        Edge { a: po[20], b: pi[11] },
        Edge { a: pi[11], b: po[24] },
        Edge { a: po[24], b: pi[13] },
        Edge { a: pi[13], b: po[28] },
        Edge { a: po[28], b: pi[15] },
        Edge { a: pi[15], b: po[32] },
        Edge { a: po[32], b: pi[17] },
        Edge { a: pi[17], b: po[36] },
        Edge { a: po[36], b: pi[19] },
        Edge { a: pi[19], b: po[40] },
        Edge { a: po[40], b: pi[21] },
        Edge { a: pi[21], b: po[44] },
        Edge { a: po[44], b: pi[23] },
        Edge { a: pi[23], b: po[0] },
    ];

    let arc_pqu = arc_polyline(l, radius_l, -159.0, 138.0, 65);
    let arc_pql = arc_polyline(m, radius_m, -180.0, 180.0, 65);
    let crisp_l = [
        xu[0], xl[1], xu[4], xl[2], xu[8], xl[3], xu[12], xl[4], xu[16], xl[5],
    ];
    let crisp_r = [
        xu[xn - 1],
        xl[xm - 2],
        xu[xn - 5],
        xl[xm - 3],
        xu[xn - 9],
        xl[xm - 4],
        xu[xn - 13],
        xl[xm - 5],
        xu[xn - 17],
        xl[xm - 6],
    ];

    let mut moon = Vec::new();
    for p in &arc_pqu {
        if p.x <= r.x {
            moon.push(*p);
        }
    }
    moon.extend_from_slice(&crisp_l);
    for p in crisp_r.iter().rev() {
        moon.push(*p);
    }
    for p in &arc_pqu {
        if p.x >= s.x {
            moon.push(*p);
        }
    }
    for p in arc_pql.iter().rev() {
        moon.push(*p);
    }

    let mut points = BTreeMap::new();
    points.insert("A", a);
    points.insert("B", bb);
    points.insert("C", c);
    points.insert("D", d);
    points.insert("E", e);
    points.insert("F", f);
    points.insert("G", g);
    points.insert("H", h);
    points.insert("I", i);
    points.insert("J", j);
    points.insert("K", k);
    points.insert("L", l);
    points.insert("M", m);
    points.insert("N", n);
    points.insert("O", o);
    points.insert("O1", o1);
    points.insert("P", p);
    points.insert("Q", q);
    points.insert("R", r);
    points.insert("S", s);
    points.insert("T", t);
    points.insert("U", u);
    points.insert("V", v);
    points.insert("W", w);

    let mut arcs = BTreeMap::new();
    arcs.insert(
        "crescent_outer",
        Arc {
            c: l,
            r: radius_l,
            t0: -159.0,
            dt: 138.0,
        },
    );
    arcs.insert(
        "crescent_inner",
        Arc {
            c: m,
            r: radius_m,
            t0: -180.0,
            dt: 180.0,
        },
    );
    arcs.insert(
        "moon_upper",
        Arc {
            c: t,
            r: radius_tu,
            t0: 180.0,
            dt: -180.0,
        },
    );
    arcs.insert(
        "moon_lower",
        Arc {
            c: t,
            r: radius_tl,
            t0: 195.0,
            dt: -210.0,
        },
    );
    arcs.insert(
        "n_arc",
        Arc {
            c: n,
            r: radius_n,
            t0: 180.0,
            dt: -180.0,
        },
    );

    let mut circles = BTreeMap::new();
    circles.insert("sun_inner", [w.x, w.y, radius_wi]);
    circles.insert("sun_outer", [w.x, w.y, radius_wo]);

    Geom {
        base_length: b,
        border_width,
        points,
        border: vec![a_bi, b_bi, e_bi, g_bi, c_bi],
        inner: vec![a, bb, e, g, c],
        moon,
        sun,
        moon_rays,
        sun_rays,
        imaginary: vec![
            Edge { a: h, b: i },
            Edge { a: j, b: k },
            Edge { a: j, b: g },
            Edge { a: o, b: o1 },
            Edge { a: r, b: s },
            Edge { a: f, b: g },
            Edge { a: u, b: v },
            Edge { a: bb, b: d },
        ],
        arcs,
        circles,
    }
}

fn fmt_f(v: f64) -> String {
    format!("{v:.4}")
}

fn poly_points(pts: &[Pt], flip: f64) -> String {
    pts.iter()
        .map(|p| format!("{},{}", fmt_f(p.x), fmt_f(flip - p.y)))
        .collect::<Vec<_>>()
        .join(" ")
}

fn write_edge(out: &mut String, a: Pt, b: Pt, flip: f64, color: &str, width: f64, dash: Option<&str>) {
    out.push_str(&format!(
        r#"<line x1="{}" y1="{}" x2="{}" y2="{}" stroke="{}" stroke-width="{width}""#,
        fmt_f(a.x),
        fmt_f(flip - a.y),
        fmt_f(b.x),
        fmt_f(flip - b.y),
        color
    ));
    if let Some(d) = dash {
        out.push_str(&format!(r#" stroke-dasharray="{d}""#));
    }
    out.push_str(" />\n");
}

fn write_arc(out: &mut String, a: Arc, flip: f64, color: &str, width: f64, dash: Option<&str>) {
    let pts = arc_polyline(a.c, a.r, a.t0, a.dt, 64);
    out.push_str(&format!(
        r#"<path d="M {},{}"#,
        fmt_f(pts[0].x),
        fmt_f(flip - pts[0].y)
    ));
    for p in pts.iter().skip(1) {
        out.push_str(&format!(" L {},{}", fmt_f(p.x), fmt_f(flip - p.y)));
    }
    out.push_str(&format!(
        r#"" fill="none" stroke="{color}" stroke-width="{width}""#
    ));
    if let Some(d) = dash {
        out.push_str(&format!(r#" stroke-dasharray="{d}""#));
    }
    out.push_str(" />\n");
}

fn to_svg(g: &Geom, mode: &str) -> String {
    let (min_x, _min_y, max_x, max_y) = g.bounds();
    let width = max_x - min_x;
    let height = max_y - _min_y;
    let flip = max_y;

    let mut out = String::new();
    out.push_str(r#"<?xml version="1.0" encoding="UTF-8"?>"#);
    out.push('\n');
    out.push_str(&format!(
        r#"<svg xmlns="http://www.w3.org/2000/svg" viewBox="{} 0 {} {}" width="{}" height="{}" role="img" aria-label="National Flag of Nepal">"#,
        fmt_f(min_x),
        fmt_f(width),
        fmt_f(height),
        width.round() as i64,
        height.round() as i64
    ));
    out.push('\n');
    out.push_str(&format!("<title>National Flag of Nepal ({mode})</title>\n"));

    if mode == "color" {
        let mut border = g.border.clone();
        border.push(g.border[0]);
        let mut inner = g.inner.clone();
        inner.push(g.inner[0]);
        let mut sun = g.sun.clone();
        sun.push(g.sun[0]);
        out.push_str(&format!(
            r#"<polygon points="{}" fill="{DEEP_BLUE}" stroke="none" />"#,
            poly_points(&border, flip)
        ));
        out.push('\n');
        out.push_str(&format!(
            r#"<polygon points="{}" fill="{CRIMSON}" stroke="none" />"#,
            poly_points(&inner, flip)
        ));
        out.push('\n');
        out.push_str(&format!(
            r#"<polygon points="{}" fill="{WHITE}" stroke="none" />"#,
            poly_points(&g.moon, flip)
        ));
        out.push('\n');
        out.push_str(&format!(
            r#"<polygon points="{}" fill="{WHITE}" stroke="none" />"#,
            poly_points(&sun, flip)
        ));
        out.push('\n');
    } else {
        let p = &g.points;
        write_edge(&mut out, p["A"], p["B"], flip, INK, 1.5, None);
        write_edge(&mut out, p["A"], p["C"], flip, INK, 1.5, None);
        write_edge(&mut out, p["E"], p["G"], flip, INK, 1.5, None);
        write_edge(&mut out, p["C"], p["G"], flip, INK, 1.5, None);
        write_edge(&mut out, p["B"], p["E"], flip, INK, 1.5, None);
        for i in 0..g.border.len() {
            write_edge(
                &mut out,
                g.border[i],
                g.border[(i + 1) % g.border.len()],
                flip,
                INK,
                1.5,
                None,
            );
        }
        for key in ["crescent_outer", "crescent_inner", "moon_lower"] {
            write_arc(&mut out, g.arcs[key], flip, INK, 1.5, None);
        }
        for e in &g.moon_rays {
            write_edge(&mut out, e.a, e.b, flip, INK, 1.5, None);
        }
        for e in &g.sun_rays {
            write_edge(&mut out, e.a, e.b, flip, INK, 1.5, None);
        }
        let ci = g.circles["sun_inner"];
        out.push_str(&format!(
            r#"<circle cx="{}" cy="{}" r="{}" fill="none" stroke="{INK}" stroke-width="1.5" />"#,
            fmt_f(ci[0]),
            fmt_f(flip - ci[1]),
            fmt_f(ci[2])
        ));
        out.push('\n');

        if mode == "landmark" {
            let fs = g.base_length * 0.035;
            for name in [
                "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P",
                "Q", "R", "S", "T", "U", "V", "W",
            ] {
                let pt = g.points[name];
                out.push_str(&format!(
                    r#"<circle cx="{}" cy="{}" r="3" fill="{INK}" />"#,
                    fmt_f(pt.x),
                    fmt_f(flip - pt.y)
                ));
                out.push('\n');
                out.push_str(&format!(
                    r#"<text x="{}" y="{}" font-family="Helvetica, Arial, sans-serif" font-size="{fs:.1}" fill="{INK}">{name}</text>"#,
                    fmt_f(pt.x + 6.0),
                    fmt_f(flip - pt.y - 6.0)
                ));
                out.push('\n');
            }
            write_arc(&mut out, g.arcs["moon_upper"], flip, IMAGINARY, 1.0, Some("6 4"));
            write_arc(&mut out, g.arcs["n_arc"], flip, IMAGINARY, 1.0, Some("6 4"));
            let co = g.circles["sun_outer"];
            out.push_str(&format!(
                r#"<circle cx="{}" cy="{}" r="{}" fill="none" stroke="{IMAGINARY}" stroke-width="1" stroke-dasharray="6 4" />"#,
                fmt_f(co[0]),
                fmt_f(flip - co[1]),
                fmt_f(co[2])
            ));
            out.push('\n');
            for e in &g.imaginary {
                write_edge(&mut out, e.a, e.b, flip, IMAGINARY, 1.0, Some("6 4"));
            }
        }
    }
    out.push_str("</svg>\n");
    out
}

fn to_html(g: &Geom) -> String {
    let titles = ["Colour flag", "Skeleton", "Landmarks"];
    let mut body = String::new();
    for (i, mode) in MODES.iter().enumerate() {
        let mut svg = to_svg(g, mode);
        if let Some(pos) = svg.find('\n') {
            if svg.starts_with("<?xml") {
                svg = svg[pos + 1..].to_string();
            }
        }
        body.push_str(&format!(
            "    <section class=\"flag\">\n      <h2>{}</h2>\n{svg}    </section>\n\n",
            titles[i]
        ));
    }
    format!(
        r#"<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>National Flag of Nepal</title>
  <style>
    body {{ margin: 0; font-family: Georgia, serif; background: #f6f4f1; color: #1a1a1a; }}
    main {{ max-width: 900px; margin: 2rem auto; padding: 0 1.25rem 3rem; }}
    h1 {{ font-weight: 400; }}
    .meta {{ color: #555; margin: 0 0 2rem; }}
    .flag {{ background: #fff; padding: 1.25rem 1.5rem 1.75rem; margin-bottom: 1.5rem; }}
    .flag h2 {{ font-weight: 400; font-size: 1.15rem; margin: 0 0 1rem; }}
    .flag svg {{ width: 100%; height: auto; display: block; }}
  </style>
</head>
<body>
  <main>
    <h1>National Flag of Nepal</h1>
    <p class="meta">Base length AB = {:.0} · Border width TN = {:.4} · Constitution of Nepal, Schedule 1, Article 8</p>
{body}  </main>
</body>
</html>
"#,
        g.base_length, g.border_width
    )
}

fn main() {
    let args: Vec<String> = env::args().collect();
    let base = args
        .get(1)
        .map(|s| s.parse::<f64>().unwrap_or_else(|_| {
            eprintln!("invalid base length");
            process::exit(1);
        }))
        .unwrap_or(800.0);
    let out_dir = args.get(2).map(String::as_str).unwrap_or("output");

    if let Err(e) = fs::create_dir_all(out_dir) {
        eprintln!("{e}");
        process::exit(1);
    }

    let g = construct(base);
    for mode in MODES {
        let path = Path::new(out_dir).join(format!("np_flag_{mode}.svg"));
        if let Err(e) = fs::write(&path, to_svg(&g, mode)) {
            eprintln!("{e}");
            process::exit(1);
        }
        println!("{}", path.display());
    }
    let html_path = Path::new(out_dir).join("np_flag.html");
    if let Err(e) = fs::write(&html_path, to_html(&g)) {
        eprintln!("{e}");
        process::exit(1);
    }
    println!("{}", html_path.display());
}
