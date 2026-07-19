// Author: Ashok Kumar Pant <asokpant@gmail.com>
// Date: July 19, 2026

const crimson = "#DC143C";
const deepBlue = "#003893";
const white = "#FFFFFF";
const ink = "#111111";
const imaginary = "#888888";

export const MODES = ["color", "skeleton", "landmark"];

function dist(a, b) {
  return Math.hypot(b.x - a.x, b.y - a.y);
}

function mid(a, b) {
  return { x: (a.x + b.x) / 2, y: (a.y + b.y) / 2 };
}

function parallelEdge(a, b, d) {
  const dx = b.x - a.x;
  const dy = b.y - a.y;
  const len = Math.hypot(dx, dy);
  const nx = dy / len;
  const ny = -dx / len;
  return [
    { x: a.x + d * nx, y: a.y + d * ny },
    { x: b.x + d * nx, y: b.y + d * ny },
  ];
}

function intersectLines(p1, d1, p2, d2) {
  const denom = d1.x * d2.y - d1.y * d2.x;
  const s =
    ((p2.x - p1.x) * d2.y - (p2.y - p1.y) * d2.x) / denom;
  return { x: p1.x + s * d1.x, y: p1.y + s * d1.y };
}

function intersectEdges(a1, a2, b1, b2) {
  return intersectLines(
    a1,
    { x: a2.x - a1.x, y: a2.y - a1.y },
    b1,
    { x: b2.x - b1.x, y: b2.y - b1.y },
  );
}

function intersectLineCircle(origin, dir, center, radius) {
  const dpx = origin.x - center.x;
  const dpy = origin.y - center.y;
  const a = dir.x * dir.x + dir.y * dir.y;
  const b = 2 * (dpx * dir.x + dpy * dir.y);
  const c = dpx * dpx + dpy * dpy - radius * radius;
  let delta = b * b - 4 * a * c;
  if (Math.abs(delta) < 1e-14) delta = 0;
  if (delta < 0) return [];
  const sqrtD = Math.sqrt(delta);
  const u1 = (-b - sqrtD) / (2 * a);
  const u2 = (-b + sqrtD) / (2 * a);
  return [
    { x: origin.x + u1 * dir.x, y: origin.y + u1 * dir.y },
    { x: origin.x + u2 * dir.x, y: origin.y + u2 * dir.y },
  ];
}

function intersectCircles(c1, r1, c2, r2) {
  const d = dist(c1, c2);
  const a = (r1 * r1 - r2 * r2 + d * d) / (2 * d);
  let h2 = r1 * r1 - a * a;
  if (Math.abs(h2) < 1e-12) h2 = 0;
  const h = Math.sqrt(h2);
  const midPt = {
    x: c1.x + (a / d) * (c2.x - c1.x),
    y: c1.y + (a / d) * (c2.y - c1.y),
  };
  const dx = c2.x - c1.x;
  const dy = c2.y - c1.y;
  const rx = -dy * (h / d);
  const ry = dx * (h / d);
  return [
    { x: midPt.x + rx, y: midPt.y + ry },
    { x: midPt.x - rx, y: midPt.y - ry },
  ];
}

function distancePointEdge(p, a, b) {
  const abx = b.x - a.x;
  const aby = b.y - a.y;
  let t = ((p.x - a.x) * abx + (p.y - a.y) * aby) / (abx * abx + aby * aby);
  t = Math.max(0, Math.min(1, t));
  return dist(p, { x: a.x + t * abx, y: a.y + t * aby });
}

function arcPolyline(c, r, t0Deg, dtDeg, n) {
  const pts = new Array(n);
  const t0 = (t0Deg * Math.PI) / 180;
  const t1 = t0 + (dtDeg * Math.PI) / 180;
  for (let i = 0; i < n; i++) {
    const t = t0 + ((t1 - t0) * i) / (n - 1);
    pts[i] = { x: c.x + r * Math.cos(t), y: c.y + r * Math.sin(t) };
  }
  return pts;
}

function circlePolygon(c, r, n) {
  const pts = new Array(n + 1);
  for (let i = 0; i <= n; i++) {
    const t = (2 * Math.PI * i) / n;
    pts[i] = { x: c.x + r * Math.cos(t), y: c.y + r * Math.sin(t) };
  }
  return pts;
}

export function construct(b) {
  const A = { x: 0, y: 0 };
  const B = { x: b, y: 0 };
  const C = { x: 0, y: b + b / 3 };
  const D = { x: 0, y: b };

  const ePts = intersectLineCircle(B, { x: D.x - B.x, y: D.y - B.y }, B, b);
  const E = ePts[1];
  const F = { x: 0, y: E.y };
  const G = { x: b, y: E.y };

  const H = { x: b / 4, y: 0 };
  const I = intersectEdges(H, { x: H.x, y: C.y }, C, G);
  const J = mid(C, F);
  const K = intersectEdges(J, { x: J.x + b, y: J.y }, C, G);
  const L = intersectEdges(J, K, H, I);
  const M = intersectEdges(J, G, H, I);
  const N = { x: M.x, y: M.y - distancePointEdge(M, B, D) };
  const O = { x: A.x, y: M.y };
  const O1 = intersectEdges(O, M, C, G);

  const radiusL = dist(L, N);
  const pq = intersectLineCircle(
    O,
    { x: M.x - O.x, y: M.y - O.y },
    L,
    radiusL,
  );
  const P = pq[0];
  const Q = pq[1];
  const radiusM = dist(M, Q);
  const radiusN = dist(N, M);
  const rs = intersectCircles(L, radiusL, N, radiusN);
  let R = rs[0];
  let S = rs[1];
  if (R.x > S.x) {
    [R, S] = [S, R];
  }
  const T = intersectEdges(R, S, H, I);
  const radiusTU = dist(T, S);
  const radiusTL = dist(T, M);

  const xu = arcPolyline(T, radiusTU, 180, -180, 38);
  const xl = arcPolyline(T, radiusTL, 195, -210, 11);

  const U = mid(A, F);
  const V = intersectEdges(U, { x: U.x + b, y: U.y }, B, E);
  const W = intersectEdges(U, V, H, I);

  const radiusWI = dist(M, N);
  const radiusWO = dist(L, N);
  const pi = circlePolygon(W, radiusWI, 24);
  const po = circlePolygon(W, radiusWO, 48);

  const borderWidth = dist(T, N);
  const g = {
    baseLength: b,
    borderWidth,
    points: {
      A,
      B,
      C,
      D,
      E,
      F,
      G,
      H,
      I,
      J,
      K,
      L,
      M,
      N,
      O,
      O1,
      P,
      Q,
      R,
      S,
      T,
      U,
      V,
      W,
    },
    inner: [A, B, E, G, C],
    arcs: {
      crescent_outer: { c: L, r: radiusL, t0: -159, dt: 138 },
      crescent_inner: { c: M, r: radiusM, t0: -180, dt: 180 },
      moon_upper: { c: T, r: radiusTU, t0: 180, dt: -180 },
      moon_lower: { c: T, r: radiusTL, t0: 195, dt: -210 },
      n_arc: { c: N, r: radiusN, t0: 180, dt: -180 },
    },
    circles: {
      sun_inner: [W.x, W.y, radiusWI],
      sun_outer: [W.x, W.y, radiusWO],
    },
    border: [],
    moon: [],
    sun: [],
    moonRays: [],
    sunRays: [],
    imaginary: [],
  };

  const [ab0, ab1] = parallelEdge(A, B, borderWidth);
  const [ac0, ac1] = parallelEdge(A, C, -borderWidth);
  const [cg0, cg1] = parallelEdge(C, G, -borderWidth);
  const [eg0, eg1] = parallelEdge(E, G, borderWidth);
  const [be0, be1] = parallelEdge(B, E, borderWidth);
  const aBi = intersectLines(
    ab0,
    { x: ab1.x - ab0.x, y: ab1.y - ab0.y },
    ac0,
    { x: ac1.x - ac0.x, y: ac1.y - ac0.y },
  );
  const cBi = intersectLines(
    ac0,
    { x: ac1.x - ac0.x, y: ac1.y - ac0.y },
    cg0,
    { x: cg1.x - cg0.x, y: cg1.y - cg0.y },
  );
  const gBi = intersectLines(
    cg0,
    { x: cg1.x - cg0.x, y: cg1.y - cg0.y },
    eg0,
    { x: eg1.x - eg0.x, y: eg1.y - eg0.y },
  );
  const eBi = intersectLines(
    eg0,
    { x: eg1.x - eg0.x, y: eg1.y - eg0.y },
    be0,
    { x: be1.x - be0.x, y: be1.y - be0.y },
  );
  const bBi = intersectLines(
    ab0,
    { x: ab1.x - ab0.x, y: ab1.y - ab0.y },
    be0,
    { x: be1.x - be0.x, y: be1.y - be0.y },
  );
  g.border = [aBi, bBi, eBi, gBi, cBi];

  const n = xu.length;
  const m = xl.length;
  g.moonRays = [
    { a: xu[0], b: xl[1] },
    { a: xu[n - 1], b: xl[m - 2] },
    { a: xl[1], b: xu[4] },
    { a: xu[4], b: xl[2] },
    { a: xl[m - 2], b: xu[n - 5] },
    { a: xu[n - 5], b: xl[m - 3] },
    { a: xl[2], b: xu[8] },
    { a: xu[8], b: xl[3] },
    { a: xl[m - 3], b: xu[n - 9] },
    { a: xu[n - 9], b: xl[m - 4] },
    { a: xl[3], b: xu[12] },
    { a: xu[12], b: xl[4] },
    { a: xl[m - 4], b: xu[n - 13] },
    { a: xu[n - 13], b: xl[m - 5] },
    { a: xl[4], b: xu[16] },
    { a: xu[16], b: xl[5] },
    { a: xl[m - 5], b: xu[n - 17] },
    { a: xu[n - 17], b: xl[m - 6] },
  ];

  const sunOrder = [
    1, 4, 3, 8, 5, 12, 7, 16, 9, 20, 11, 24, 13, 28, 15, 32, 17, 36, 19, 40, 21,
    44, 23, 0,
  ];
  for (let i = 0; i < sunOrder.length; i += 2) {
    g.sun.push(pi[sunOrder[i]], po[sunOrder[i + 1]]);
  }
  g.sunRays = [
    { a: pi[1], b: po[0] },
    { a: pi[1], b: po[4] },
    { a: po[4], b: pi[3] },
    { a: pi[3], b: po[8] },
    { a: po[8], b: pi[5] },
    { a: pi[5], b: po[12] },
    { a: po[12], b: pi[7] },
    { a: pi[7], b: po[16] },
    { a: po[16], b: pi[9] },
    { a: pi[9], b: po[20] },
    { a: po[20], b: pi[11] },
    { a: pi[11], b: po[24] },
    { a: po[24], b: pi[13] },
    { a: pi[13], b: po[28] },
    { a: po[28], b: pi[15] },
    { a: pi[15], b: po[32] },
    { a: po[32], b: pi[17] },
    { a: pi[17], b: po[36] },
    { a: po[36], b: pi[19] },
    { a: pi[19], b: po[40] },
    { a: po[40], b: pi[21] },
    { a: pi[21], b: po[44] },
    { a: po[44], b: pi[23] },
    { a: pi[23], b: po[0] },
  ];

  const arcPqu = arcPolyline(L, radiusL, -159, 138, 65);
  const arcPql = arcPolyline(M, radiusM, -180, 180, 65);
  const crispL = [
    xu[0],
    xl[1],
    xu[4],
    xl[2],
    xu[8],
    xl[3],
    xu[12],
    xl[4],
    xu[16],
    xl[5],
  ];
  const crispR = [
    xu[n - 1],
    xl[m - 2],
    xu[n - 5],
    xl[m - 3],
    xu[n - 9],
    xl[m - 4],
    xu[n - 13],
    xl[m - 5],
    xu[n - 17],
    xl[m - 6],
  ];
  for (const p of arcPqu) {
    if (p.x <= R.x) g.moon.push(p);
  }
  g.moon.push(...crispL);
  for (let i = crispR.length - 1; i >= 0; i--) {
    g.moon.push(crispR[i]);
  }
  for (const p of arcPqu) {
    if (p.x >= S.x) g.moon.push(p);
  }
  for (let i = arcPql.length - 1; i >= 0; i--) {
    g.moon.push(arcPql[i]);
  }

  g.imaginary = [
    { a: H, b: I },
    { a: J, b: K },
    { a: J, b: G },
    { a: O, b: O1 },
    { a: R, b: S },
    { a: F, b: G },
    { a: U, b: V },
    { a: B, b: D },
  ];
  return g;
}

function bounds(g) {
  let minX = Infinity;
  let minY = Infinity;
  let maxX = -Infinity;
  let maxY = -Infinity;
  const expand = (p) => {
    minX = Math.min(minX, p.x);
    minY = Math.min(minY, p.y);
    maxX = Math.max(maxX, p.x);
    maxY = Math.max(maxY, p.y);
  };
  for (const poly of [g.border, g.inner, g.moon, g.sun]) {
    for (const p of poly) expand(p);
  }
  for (const p of Object.values(g.points)) expand(p);
  let pad = g.baseLength * 0.02;
  if (g.borderWidth > 0) pad = g.borderWidth * 0.5;
  return { minX: minX - pad, minY: minY - pad, maxX: maxX + pad, maxY: maxY + pad };
}

function fmtF(v) {
  return v.toFixed(4);
}

function polyPoints(pts, flip) {
  return pts.map((p) => `${fmtF(p.x)},${fmtF(flip - p.y)}`).join(" ");
}

function writeEdge(b, a, c, flip, color, width, dash) {
  let s =
    `<line x1="${fmtF(a.x)}" y1="${fmtF(flip - a.y)}" x2="${fmtF(c.x)}" y2="${fmtF(flip - c.y)}" stroke="${color}" stroke-width="${width}"`;
  if (dash !== "") s += ` stroke-dasharray="${dash}"`;
  b.push(s + " />\n");
}

function writeArc(b, a, flip, color, width, dash) {
  const pts = arcPolyline(a.c, a.r, a.t0, a.dt, 64);
  let d = `M ${fmtF(pts[0].x)},${fmtF(flip - pts[0].y)}`;
  for (let i = 1; i < pts.length; i++) {
    d += ` L ${fmtF(pts[i].x)},${fmtF(flip - pts[i].y)}`;
  }
  let s = `<path d="${d}" fill="none" stroke="${color}" stroke-width="${width}"`;
  if (dash !== "") s += ` stroke-dasharray="${dash}"`;
  b.push(s + " />\n");
}

export function toSVG(g, mode) {
  const { minX, minY, maxX, maxY } = bounds(g);
  const flip = maxY;
  const w = maxX - minX;
  const h = maxY - minY;

  const parts = [];
  parts.push('<?xml version="1.0" encoding="UTF-8"?>\n');
  parts.push(
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="${fmtF(minX)} 0 ${fmtF(w)} ${fmtF(h)}" width="${Math.round(w)}" height="${Math.round(h)}" role="img" aria-label="National Flag of Nepal">\n`,
  );
  parts.push(`<title>National Flag of Nepal (${mode})</title>\n`);

  if (mode === "color") {
    const border = [...g.border, g.border[0]];
    const inner = [...g.inner, g.inner[0]];
    const sun = [...g.sun, g.sun[0]];
    parts.push(
      `<polygon points="${polyPoints(border, flip)}" fill="${deepBlue}" stroke="none" />\n`,
    );
    parts.push(
      `<polygon points="${polyPoints(inner, flip)}" fill="${crimson}" stroke="none" />\n`,
    );
    parts.push(
      `<polygon points="${polyPoints(g.moon, flip)}" fill="${white}" stroke="none" />\n`,
    );
    parts.push(
      `<polygon points="${polyPoints(sun, flip)}" fill="${white}" stroke="none" />\n`,
    );
  } else {
    const p = g.points;
    writeEdge(parts, p.A, p.B, flip, ink, 1.5, "");
    writeEdge(parts, p.A, p.C, flip, ink, 1.5, "");
    writeEdge(parts, p.E, p.G, flip, ink, 1.5, "");
    writeEdge(parts, p.C, p.G, flip, ink, 1.5, "");
    writeEdge(parts, p.B, p.E, flip, ink, 1.5, "");
    for (let i = 0; i < g.border.length; i++) {
      writeEdge(
        parts,
        g.border[i],
        g.border[(i + 1) % g.border.length],
        flip,
        ink,
        1.5,
        "",
      );
    }
    for (const key of ["crescent_outer", "crescent_inner", "moon_lower"]) {
      writeArc(parts, g.arcs[key], flip, ink, 1.5, "");
    }
    for (const e of g.moonRays) {
      writeEdge(parts, e.a, e.b, flip, ink, 1.5, "");
    }
    for (const e of g.sunRays) {
      writeEdge(parts, e.a, e.b, flip, ink, 1.5, "");
    }
    const ci = g.circles.sun_inner;
    parts.push(
      `<circle cx="${fmtF(ci[0])}" cy="${fmtF(flip - ci[1])}" r="${fmtF(ci[2])}" fill="none" stroke="${ink}" stroke-width="1.5" />\n`,
    );

    if (mode === "landmark") {
      const fs = g.baseLength * 0.035;
      for (const name of [
        "A",
        "B",
        "C",
        "D",
        "E",
        "F",
        "G",
        "H",
        "I",
        "J",
        "K",
        "L",
        "M",
        "N",
        "O",
        "P",
        "Q",
        "R",
        "S",
        "T",
        "U",
        "V",
        "W",
      ]) {
        const pt = g.points[name];
        parts.push(
          `<circle cx="${fmtF(pt.x)}" cy="${fmtF(flip - pt.y)}" r="3" fill="${ink}" />\n`,
        );
        parts.push(
          `<text x="${fmtF(pt.x + 6)}" y="${fmtF(flip - pt.y - 6)}" font-family="Helvetica, Arial, sans-serif" font-size="${fs.toFixed(1)}" fill="${ink}">${name}</text>\n`,
        );
      }
      writeArc(parts, g.arcs.moon_upper, flip, imaginary, 1, "6 4");
      writeArc(parts, g.arcs.n_arc, flip, imaginary, 1, "6 4");
      const co = g.circles.sun_outer;
      parts.push(
        `<circle cx="${fmtF(co[0])}" cy="${fmtF(flip - co[1])}" r="${fmtF(co[2])}" fill="none" stroke="${imaginary}" stroke-width="1" stroke-dasharray="6 4" />\n`,
      );
      for (const e of g.imaginary) {
        writeEdge(parts, e.a, e.b, flip, imaginary, 1, "6 4");
      }
    }
  }
  parts.push("</svg>\n");
  return parts.join("");
}

export function toHTML(g) {
  const titles = ["Colour flag", "Skeleton", "Landmarks"];
  let body = "";
  for (let i = 0; i < MODES.length; i++) {
    let svg = toSVG(g, MODES[i]);
    if (svg.startsWith("<?xml")) {
      const idx = svg.indexOf("\n");
      if (idx >= 0) svg = svg.slice(idx + 1);
    }
    body += `    <section class="flag">\n      <h2>${titles[i]}</h2>\n`;
    body += svg;
    body += "    </section>\n\n";
  }
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>National Flag of Nepal</title>
  <style>
    body { margin: 0; font-family: Georgia, serif; background: #f6f4f1; color: #1a1a1a; }
    main { max-width: 900px; margin: 2rem auto; padding: 0 1.25rem 3rem; }
    h1 { font-weight: 400; }
    .meta { color: #555; margin: 0 0 2rem; }
    .flag { background: #fff; padding: 1.25rem 1.5rem 1.75rem; margin-bottom: 1.5rem; }
    .flag h2 { font-weight: 400; font-size: 1.15rem; margin: 0 0 1rem; }
    .flag svg { width: 100%; height: auto; display: block; }
  </style>
</head>
<body>
  <main>
    <h1>National Flag of Nepal</h1>
    <p class="meta">Base length AB = ${g.baseLength.toFixed(0)} · Border width TN = ${g.borderWidth.toFixed(4)} · Constitution of Nepal, Schedule 1, Article 8</p>
${body}  </main>
</body>
</html>
`;
}
