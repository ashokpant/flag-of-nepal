// National Flag of Nepal — constitutional geometry (Schedule 1, Article 8).
// Author: Ashok Pant <asokpant@gmail.com>
// Date: July 19, 2026
// Uses:
//	./flag-of-nepal [baseLength] [outputDir]

#include <algorithm>
#include <array>
#include <cmath>
#include <filesystem>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <limits>
#include <map>
#include <sstream>
#include <string>
#include <vector>

namespace fs = std::filesystem;

const std::string crimson = "#DC143C";
const std::string deepBlue = "#003893";
const std::string white = "#FFFFFF";
const std::string ink = "#111111";
const std::string imaginary = "#888888";

const std::vector<std::string> modes = {"color", "skeleton", "landmark"};

struct Pt {
  double x, y;
};

struct Edge {
  Pt a, b;
};

struct Arc {
  Pt c;
  double r, t0, dt;
};

struct Geom {
  double baseLength = 0;
  double borderWidth = 0;
  std::map<std::string, Pt> points;
  std::vector<Pt> border, inner, moon, sun;
  std::vector<Edge> moonRays, sunRays, imaginary;
  std::map<std::string, Arc> arcs;
  std::map<std::string, std::array<double, 3>> circles;
};

static double dist(Pt a, Pt b) { return std::hypot(b.x - a.x, b.y - a.y); }

static Pt mid(Pt a, Pt b) { return {(a.x + b.x) / 2, (a.y + b.y) / 2}; }

static void parallelEdge(Pt a, Pt b, double d, Pt& o0, Pt& o1) {
  double dx = b.x - a.x, dy = b.y - a.y;
  double len = std::hypot(dx, dy);
  double nx = dy / len, ny = -dx / len;
  o0 = {a.x + d * nx, a.y + d * ny};
  o1 = {b.x + d * nx, b.y + d * ny};
}

static Pt intersectLines(Pt p1, Pt d1, Pt p2, Pt d2) {
  double denom = d1.x * d2.y - d1.y * d2.x;
  double s = ((p2.x - p1.x) * d2.y - (p2.y - p1.y) * d2.x) / denom;
  return {p1.x + s * d1.x, p1.y + s * d1.y};
}

static Pt intersectEdges(Pt a1, Pt a2, Pt b1, Pt b2) {
  return intersectLines(a1, {a2.x - a1.x, a2.y - a1.y}, b1,
                        {b2.x - b1.x, b2.y - b1.y});
}

static std::vector<Pt> intersectLineCircle(Pt origin, Pt dir, Pt center,
                                           double radius) {
  double dpx = origin.x - center.x, dpy = origin.y - center.y;
  double a = dir.x * dir.x + dir.y * dir.y;
  double b = 2 * (dpx * dir.x + dpy * dir.y);
  double c = dpx * dpx + dpy * dpy - radius * radius;
  double delta = b * b - 4 * a * c;
  if (std::abs(delta) < 1e-14) delta = 0;
  if (delta < 0) return {};
  double sqrtD = std::sqrt(delta);
  double u1 = (-b - sqrtD) / (2 * a);
  double u2 = (-b + sqrtD) / (2 * a);
  return {{origin.x + u1 * dir.x, origin.y + u1 * dir.y},
          {origin.x + u2 * dir.x, origin.y + u2 * dir.y}};
}

static std::vector<Pt> intersectCircles(Pt c1, double r1, Pt c2, double r2) {
  double d = dist(c1, c2);
  double a = (r1 * r1 - r2 * r2 + d * d) / (2 * d);
  double h2 = r1 * r1 - a * a;
  if (std::abs(h2) < 1e-12) h2 = 0;
  double h = std::sqrt(h2);
  Pt midPt = {c1.x + a / d * (c2.x - c1.x), c1.y + a / d * (c2.y - c1.y)};
  double dx = c2.x - c1.x, dy = c2.y - c1.y;
  double rx = -dy * (h / d), ry = dx * (h / d);
  return {{midPt.x + rx, midPt.y + ry}, {midPt.x - rx, midPt.y - ry}};
}

static double distancePointEdge(Pt p, Pt a, Pt b) {
  double abx = b.x - a.x, aby = b.y - a.y;
  double t = ((p.x - a.x) * abx + (p.y - a.y) * aby) / (abx * abx + aby * aby);
  t = std::max(0.0, std::min(1.0, t));
  return dist(p, {a.x + t * abx, a.y + t * aby});
}

static std::vector<Pt> arcPolyline(Pt c, double r, double t0Deg, double dtDeg,
                                   int n) {
  std::vector<Pt> pts(n);
  double t0 = t0Deg * M_PI / 180;
  double t1 = t0 + dtDeg * M_PI / 180;
  for (int i = 0; i < n; i++) {
    double t = t0 + (t1 - t0) * static_cast<double>(i) / (n - 1);
    pts[i] = {c.x + r * std::cos(t), c.y + r * std::sin(t)};
  }
  return pts;
}

static std::vector<Pt> circlePolygon(Pt c, double r, int n) {
  std::vector<Pt> pts(n + 1);
  for (int i = 0; i <= n; i++) {
    double t = 2 * M_PI * static_cast<double>(i) / n;
    pts[i] = {c.x + r * std::cos(t), c.y + r * std::sin(t)};
  }
  return pts;
}

static void bounds(const Geom& g, double& minX, double& minY, double& maxX,
                   double& maxY) {
  minX = minY = std::numeric_limits<double>::infinity();
  maxX = maxY = -std::numeric_limits<double>::infinity();
  auto expand = [&](Pt p) {
    minX = std::min(minX, p.x);
    minY = std::min(minY, p.y);
    maxX = std::max(maxX, p.x);
    maxY = std::max(maxY, p.y);
  };
  for (const auto& poly :
       {g.border, g.inner, g.moon, g.sun}) {
    for (Pt p : poly) expand(p);
  }
  for (const auto& kv : g.points) expand(kv.second);
  double pad = g.baseLength * 0.02;
  if (g.borderWidth > 0) pad = g.borderWidth * 0.5;
  minX -= pad;
  minY -= pad;
  maxX += pad;
  maxY += pad;
}

static Geom construct(double b) {
  Pt A = {0, 0};
  Pt B = {b, 0};
  Pt C = {0, b + b / 3};
  Pt D = {0, b};

  auto ePts = intersectLineCircle(B, {D.x - B.x, D.y - B.y}, B, b);
  Pt E = ePts[1];
  Pt F = {0, E.y};
  Pt G = {b, E.y};

  Pt H = {b / 4, 0};
  Pt I = intersectEdges(H, {H.x, C.y}, C, G);
  Pt J = mid(C, F);
  Pt K = intersectEdges(J, {J.x + b, J.y}, C, G);
  Pt L = intersectEdges(J, K, H, I);
  Pt M = intersectEdges(J, G, H, I);
  Pt N = {M.x, M.y - distancePointEdge(M, B, D)};
  Pt O = {A.x, M.y};
  Pt O1 = intersectEdges(O, M, C, G);

  double radiusL = dist(L, N);
  auto pq = intersectLineCircle(O, {M.x - O.x, M.y - O.y}, L, radiusL);
  Pt P = pq[0], Q = pq[1];
  double radiusM = dist(M, Q);
  double radiusN = dist(N, M);
  auto rs = intersectCircles(L, radiusL, N, radiusN);
  Pt R = rs[0], S = rs[1];
  if (R.x > S.x) std::swap(R, S);
  Pt T = intersectEdges(R, S, H, I);
  double radiusTU = dist(T, S);
  double radiusTL = dist(T, M);

  auto xu = arcPolyline(T, radiusTU, 180, -180, 38);
  auto xl = arcPolyline(T, radiusTL, 195, -210, 11);

  Pt U = mid(A, F);
  Pt V = intersectEdges(U, {U.x + b, U.y}, B, E);
  Pt W = intersectEdges(U, V, H, I);

  double radiusWI = dist(M, N);
  double radiusWO = dist(L, N);
  auto pi = circlePolygon(W, radiusWI, 24);
  auto po = circlePolygon(W, radiusWO, 48);

  double borderWidth = dist(T, N);
  Geom g;
  g.baseLength = b;
  g.borderWidth = borderWidth;
  g.points = {{"A", A},   {"B", B},   {"C", C},   {"D", D},   {"E", E},
              {"F", F},   {"G", G},   {"H", H},   {"I", I},   {"J", J},
              {"K", K},   {"L", L},   {"M", M},   {"N", N},   {"O", O},
              {"O1", O1}, {"P", P},   {"Q", Q},   {"R", R},   {"S", S},
              {"T", T},   {"U", U},   {"V", V},   {"W", W}};
  g.inner = {A, B, E, G, C};
  g.arcs = {{"crescent_outer", {L, radiusL, -159, 138}},
            {"crescent_inner", {M, radiusM, -180, 180}},
            {"moon_upper", {T, radiusTU, 180, -180}},
            {"moon_lower", {T, radiusTL, 195, -210}},
            {"n_arc", {N, radiusN, 180, -180}}};
  g.circles = {{"sun_inner", {W.x, W.y, radiusWI}},
               {"sun_outer", {W.x, W.y, radiusWO}}};

  Pt ab0, ab1, ac0, ac1, cg0, cg1, eg0, eg1, be0, be1;
  parallelEdge(A, B, borderWidth, ab0, ab1);
  parallelEdge(A, C, -borderWidth, ac0, ac1);
  parallelEdge(C, G, -borderWidth, cg0, cg1);
  parallelEdge(E, G, borderWidth, eg0, eg1);
  parallelEdge(B, E, borderWidth, be0, be1);
  Pt aBi = intersectLines(ab0, {ab1.x - ab0.x, ab1.y - ab0.y}, ac0,
                          {ac1.x - ac0.x, ac1.y - ac0.y});
  Pt cBi = intersectLines(ac0, {ac1.x - ac0.x, ac1.y - ac0.y}, cg0,
                          {cg1.x - cg0.x, cg1.y - cg0.y});
  Pt gBi = intersectLines(cg0, {cg1.x - cg0.x, cg1.y - cg0.y}, eg0,
                          {eg1.x - eg0.x, eg1.y - eg0.y});
  Pt eBi = intersectLines(eg0, {eg1.x - eg0.x, eg1.y - eg0.y}, be0,
                          {be1.x - be0.x, be1.y - be0.y});
  Pt bBi = intersectLines(ab0, {ab1.x - ab0.x, ab1.y - ab0.y}, be0,
                          {be1.x - be0.x, be1.y - be0.y});
  g.border = {aBi, bBi, eBi, gBi, cBi};

  int n = static_cast<int>(xu.size()), m = static_cast<int>(xl.size());
  g.moonRays = {{xu[0], xl[1]},
                {xu[n - 1], xl[m - 2]},
                {xl[1], xu[4]},
                {xu[4], xl[2]},
                {xl[m - 2], xu[n - 5]},
                {xu[n - 5], xl[m - 3]},
                {xl[2], xu[8]},
                {xu[8], xl[3]},
                {xl[m - 3], xu[n - 9]},
                {xu[n - 9], xl[m - 4]},
                {xl[3], xu[12]},
                {xu[12], xl[4]},
                {xl[m - 4], xu[n - 13]},
                {xu[n - 13], xl[m - 5]},
                {xl[4], xu[16]},
                {xu[16], xl[5]},
                {xl[m - 5], xu[n - 17]},
                {xu[n - 17], xl[m - 6]}};

  static const int sunOrder[] = {1,  4,  3,  8,  5,  12, 7,  16, 9,  20, 11, 24,
                                 13, 28, 15, 32, 17, 36, 19, 40, 21, 44, 23, 0};
  for (size_t i = 0; i < sizeof(sunOrder) / sizeof(sunOrder[0]); i += 2) {
    g.sun.push_back(pi[sunOrder[i]]);
    g.sun.push_back(po[sunOrder[i + 1]]);
  }
  g.sunRays = {{pi[1], po[0]},   {pi[1], po[4]},   {po[4], pi[3]},   {pi[3], po[8]},
               {po[8], pi[5]},   {pi[5], po[12]},  {po[12], pi[7]},  {pi[7], po[16]},
               {po[16], pi[9]}, {pi[9], po[20]},  {po[20], pi[11]}, {pi[11], po[24]},
               {po[24], pi[13]}, {pi[13], po[28]}, {po[28], pi[15]}, {pi[15], po[32]},
               {po[32], pi[17]}, {pi[17], po[36]}, {po[36], pi[19]}, {pi[19], po[40]},
               {po[40], pi[21]}, {pi[21], po[44]}, {po[44], pi[23]}, {pi[23], po[0]}};

  auto arcPqu = arcPolyline(L, radiusL, -159, 138, 65);
  auto arcPql = arcPolyline(M, radiusM, -180, 180, 65);
  std::vector<Pt> crispL = {xu[0], xl[1], xu[4],  xl[2], xu[8],
                            xl[3], xu[12], xl[4], xu[16], xl[5]};
  std::vector<Pt> crispR = {xu[n - 1], xl[m - 2], xu[n - 5], xl[m - 3], xu[n - 9],
                            xl[m - 4], xu[n - 13], xl[m - 5], xu[n - 17], xl[m - 6]};
  for (Pt p : arcPqu) {
    if (p.x <= R.x) g.moon.push_back(p);
  }
  for (Pt p : crispL) g.moon.push_back(p);
  for (int i = static_cast<int>(crispR.size()) - 1; i >= 0; i--)
    g.moon.push_back(crispR[i]);
  for (Pt p : arcPqu) {
    if (p.x >= S.x) g.moon.push_back(p);
  }
  for (int i = static_cast<int>(arcPql.size()) - 1; i >= 0; i--)
    g.moon.push_back(arcPql[i]);

  g.imaginary = {{H, I}, {J, K}, {J, G}, {O, O1}, {R, S}, {F, G}, {U, V}, {B, D}};
  return g;
}

static std::string fmtF(double v) {
  std::ostringstream os;
  os << std::fixed << std::setprecision(4) << v;
  return os.str();
}

static std::string fmtG(double v) {
  std::ostringstream os;
  os << std::defaultfloat << v;
  std::string s = os.str();
  if (s.find('.') != std::string::npos) {
    while (!s.empty() && s.back() == '0') s.pop_back();
    if (!s.empty() && s.back() == '.') s.pop_back();
  }
  return s;
}

static std::string polyPoints(const std::vector<Pt>& pts, double flip) {
  std::ostringstream os;
  for (size_t i = 0; i < pts.size(); i++) {
    if (i) os << ' ';
    os << fmtF(pts[i].x) << ',' << fmtF(flip - pts[i].y);
  }
  return os.str();
}

static void writeEdge(std::ostringstream& b, Pt a, Pt c, double flip,
                      const std::string& color, double width,
                      const std::string& dash) {
  b << "<line x1=\"" << fmtF(a.x) << "\" y1=\"" << fmtF(flip - a.y) << "\" x2=\""
    << fmtF(c.x) << "\" y2=\"" << fmtF(flip - c.y) << "\" stroke=\"" << color
    << "\" stroke-width=\"" << fmtG(width) << "\"";
  if (!dash.empty()) b << " stroke-dasharray=\"" << dash << "\"";
  b << " />\n";
}

static void writeArc(std::ostringstream& b, Arc a, double flip,
                     const std::string& color, double width,
                     const std::string& dash) {
  auto pts = arcPolyline(a.c, a.r, a.t0, a.dt, 64);
  b << "<path d=\"M " << fmtF(pts[0].x) << ',' << fmtF(flip - pts[0].y);
  for (size_t i = 1; i < pts.size(); i++)
    b << " L " << fmtF(pts[i].x) << ',' << fmtF(flip - pts[i].y);
  b << "\" fill=\"none\" stroke=\"" << color << "\" stroke-width=\"" << fmtG(width)
    << "\"";
  if (!dash.empty()) b << " stroke-dasharray=\"" << dash << "\"";
  b << " />\n";
}

static std::string toSVG(const Geom& g, const std::string& mode) {
  double minX, minY, maxX, maxY;
  bounds(g, minX, minY, maxX, maxY);
  double width = maxX - minX, height = maxY - minY;
  double flip = maxY;
  (void)minY;

  std::ostringstream b;
  b << "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
  b << "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"" << fmtF(minX)
    << " 0 " << fmtF(width) << ' ' << fmtF(height) << "\" width=\""
    << static_cast<int>(std::lround(width)) << "\" height=\""
    << static_cast<int>(std::lround(height))
    << "\" role=\"img\" aria-label=\"National Flag of Nepal\">\n";
  b << "<title>National Flag of Nepal (" << mode << ")</title>\n";

  if (mode == "color") {
    std::vector<Pt> border = g.border;
    border.push_back(g.border[0]);
    std::vector<Pt> inner = g.inner;
    inner.push_back(g.inner[0]);
    std::vector<Pt> sun = g.sun;
    sun.push_back(g.sun[0]);
    b << "<polygon points=\"" << polyPoints(border, flip) << "\" fill=\"" << deepBlue
      << "\" stroke=\"none\" />\n";
    b << "<polygon points=\"" << polyPoints(inner, flip) << "\" fill=\"" << crimson
      << "\" stroke=\"none\" />\n";
    b << "<polygon points=\"" << polyPoints(g.moon, flip) << "\" fill=\"" << white
      << "\" stroke=\"none\" />\n";
    b << "<polygon points=\"" << polyPoints(sun, flip) << "\" fill=\"" << white
      << "\" stroke=\"none\" />\n";
  } else {
    const auto& p = g.points;
    writeEdge(b, p.at("A"), p.at("B"), flip, ink, 1.5, "");
    writeEdge(b, p.at("A"), p.at("C"), flip, ink, 1.5, "");
    writeEdge(b, p.at("E"), p.at("G"), flip, ink, 1.5, "");
    writeEdge(b, p.at("C"), p.at("G"), flip, ink, 1.5, "");
    writeEdge(b, p.at("B"), p.at("E"), flip, ink, 1.5, "");
    for (size_t i = 0; i < g.border.size(); i++)
      writeEdge(b, g.border[i], g.border[(i + 1) % g.border.size()], flip, ink,
                1.5, "");
    for (const char* key : {"crescent_outer", "crescent_inner", "moon_lower"})
      writeArc(b, g.arcs.at(key), flip, ink, 1.5, "");
    for (const Edge& e : g.moonRays) writeEdge(b, e.a, e.b, flip, ink, 1.5, "");
    for (const Edge& e : g.sunRays) writeEdge(b, e.a, e.b, flip, ink, 1.5, "");
    const auto& ci = g.circles.at("sun_inner");
    b << "<circle cx=\"" << fmtF(ci[0]) << "\" cy=\"" << fmtF(flip - ci[1])
      << "\" r=\"" << fmtF(ci[2]) << "\" fill=\"none\" stroke=\"" << ink
      << "\" stroke-width=\"1.5\" />\n";

    if (mode == "landmark") {
      double fs = g.baseLength * 0.035;
      static const char* names[] = {"A", "B", "C", "D", "E", "F", "G", "H", "I",
                                    "J", "K", "L", "M", "N", "O", "P", "Q", "R",
                                    "S", "T", "U", "V", "W"};
      for (const char* name : names) {
        Pt pt = g.points.at(name);
        b << "<circle cx=\"" << fmtF(pt.x) << "\" cy=\"" << fmtF(flip - pt.y)
          << "\" r=\"3\" fill=\"" << ink << "\" />\n";
        b << "<text x=\"" << fmtF(pt.x + 6) << "\" y=\"" << fmtF(flip - pt.y - 6)
          << "\" font-family=\"Helvetica, Arial, sans-serif\" font-size=\""
          << std::fixed << std::setprecision(1) << fs << std::defaultfloat
          << "\" fill=\"" << ink << "\">" << name << "</text>\n";
      }
      writeArc(b, g.arcs.at("moon_upper"), flip, imaginary, 1, "6 4");
      writeArc(b, g.arcs.at("n_arc"), flip, imaginary, 1, "6 4");
      const auto& co = g.circles.at("sun_outer");
      b << "<circle cx=\"" << fmtF(co[0]) << "\" cy=\"" << fmtF(flip - co[1])
        << "\" r=\"" << fmtF(co[2]) << "\" fill=\"none\" stroke=\"" << imaginary
        << "\" stroke-width=\"1\" stroke-dasharray=\"6 4\" />\n";
      for (const Edge& e : g.imaginary)
        writeEdge(b, e.a, e.b, flip, imaginary, 1, "6 4");
    }
  }
  b << "</svg>\n";
  return b.str();
}

static std::string toHTML(const Geom& g) {
  static const char* titles[] = {"Colour flag", "Skeleton", "Landmarks"};
  std::ostringstream body;
  for (size_t i = 0; i < modes.size(); i++) {
    std::string svg = toSVG(g, modes[i]);
    if (svg.rfind("<?xml", 0) == 0) {
      size_t idx = svg.find('\n');
      if (idx != std::string::npos) svg = svg.substr(idx + 1);
    }
    body << "    <section class=\"flag\">\n      <h2>" << titles[i] << "</h2>\n";
    body << svg;
    body << "    </section>\n\n";
  }
  std::ostringstream html;
  html << "<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n";
  html << "  <meta charset=\"utf-8\" />\n";
  html << "  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\" />\n";
  html << "  <title>National Flag of Nepal</title>\n";
  html << "  <style>\n";
  html << "    body { margin: 0; font-family: Georgia, serif; background: #f6f4f1; color: #1a1a1a; }\n";
  html << "    main { max-width: 900px; margin: 2rem auto; padding: 0 1.25rem 3rem; }\n";
  html << "    h1 { font-weight: 400; }\n";
  html << "    .meta { color: #555; margin: 0 0 2rem; }\n";
  html << "    .flag { background: #fff; padding: 1.25rem 1.5rem 1.75rem; margin-bottom: 1.5rem; }\n";
  html << "    .flag h2 { font-weight: 400; font-size: 1.15rem; margin: 0 0 1rem; }\n";
  html << "    .flag svg { width: 100%; height: auto; display: block; }\n";
  html << "  </style>\n</head>\n<body>\n  <main>\n";
  html << "    <h1>National Flag of Nepal</h1>\n";
  html << "    <p class=\"meta\">Base length AB = " << std::fixed << std::setprecision(0)
       << g.baseLength << std::defaultfloat << " · Border width TN = "
       << std::fixed << std::setprecision(4) << g.borderWidth
       << std::defaultfloat
       << " · Constitution of Nepal, Schedule 1, Article 8</p>\n";
  html << body.str();
  html << "  </main>\n</body>\n</html>\n";
  return html.str();
}

static void writeFile(const fs::path& path, const std::string& content) {
  std::ofstream out(path);
  if (!out) {
    std::cerr << "failed to write " << path << '\n';
    std::exit(1);
  }
  out << content;
}

int main(int argc, char* argv[]) {
  double base = 800.0;
  std::string outDir = "output";
  if (argc > 1) {
    try {
      base = std::stod(argv[1]);
    } catch (...) {
      std::cerr << "invalid base length\n";
      return 1;
    }
  }
  if (argc > 2) outDir = argv[2];

  std::error_code ec;
  fs::create_directories(outDir, ec);
  if (ec) {
    std::cerr << ec.message() << '\n';
    return 1;
  }

  Geom g = construct(base);
  for (const std::string& mode : modes) {
    fs::path path = fs::path(outDir) / ("np_flag_" + mode + ".svg");
    writeFile(path, toSVG(g, mode));
    std::cout << path.string() << '\n';
  }
  fs::path htmlPath = fs::path(outDir) / "np_flag.html";
  writeFile(htmlPath, toHTML(g));
  std::cout << htmlPath.string() << '\n';
  return 0;
}
