"""
Author: Ashok Kumar Pant <asokpant@gmail.com>
Date: July 19, 2026
"""

from __future__ import annotations

import logging
import math
from dataclasses import dataclass, field
from typing import Iterable

logger = logging.getLogger(__name__)

Point = tuple[float, float]


def _dist(a: Point, b: Point) -> float:
    return math.hypot(b[0] - a[0], b[1] - a[1])


def _mid(a: Point, b: Point) -> Point:
    return ((a[0] + b[0]) / 2.0, (a[1] + b[1]) / 2.0)


def _sub(a: Point, b: Point) -> Point:
    return (a[0] - b[0], a[1] - b[1])


def _add(a: Point, b: Point) -> Point:
    return (a[0] + b[0], a[1] + b[1])


def _scale(v: Point, s: float) -> Point:
    return (v[0] * s, v[1] * s)


def _dot(a: Point, b: Point) -> float:
    return a[0] * b[0] + a[1] * b[1]


def parallel_edge(p1: Point, p2: Point, dist: float) -> tuple[Point, Point]:
    """Edge parallel to ``p1→p2`` at signed distance (positive = right side)."""
    dx, dy = p2[0] - p1[0], p2[1] - p1[1]
    length = math.hypot(dx, dy)
    # Right-side unit normal (clockwise 90°), matching geom2d parallelLine.
    nx, ny = dy / length, -dx / length
    offset = (dist * nx, dist * ny)
    return _add(p1, offset), _add(p2, offset)


def intersect_lines(p1: Point, d1: Point, p2: Point, d2: Point) -> Point:
    """Intersection of lines ``p1 + s*d1`` and ``p2 + t*d2``."""
    denom = d1[0] * d2[1] - d1[1] * d2[0]
    if abs(denom) < 1e-14:
        raise ValueError("parallel lines do not intersect")
    sx, sy = p2[0] - p1[0], p2[1] - p1[1]
    s = (sx * d2[1] - sy * d2[0]) / denom
    return (p1[0] + s * d1[0], p1[1] + s * d1[1])


def intersect_edges(a1: Point, a2: Point, b1: Point, b2: Point) -> Point:
    return intersect_lines(a1, _sub(a2, a1), b1, _sub(b2, b1))


def intersect_line_circle(
    origin: Point, direction: Point, center: Point, radius: float
) -> list[Point]:
    """Return 0–2 intersection points, ordered by line parameter (geom2d-compatible)."""
    dp = _sub(origin, center)
    a = _dot(direction, direction)
    b = 2.0 * _dot(dp, direction)
    c = _dot(dp, dp) - radius * radius
    delta = b * b - 4.0 * a * c
    if delta < 0 and abs(delta) < 1e-14:
        delta = 0.0
    if delta < 0:
        return []
    sqrt_d = math.sqrt(delta)
    u1 = (-b - sqrt_d) / (2.0 * a)
    u2 = (-b + sqrt_d) / (2.0 * a)
    p1 = _add(origin, _scale(direction, u1))
    if abs(delta) < 1e-14:
        return [p1]
    p2 = _add(origin, _scale(direction, u2))
    return [p1, p2]


def intersect_circles(c1: Point, r1: float, c2: Point, r2: float) -> list[Point]:
    """Two-circle intersections (geom2d ordering)."""
    d = _dist(c1, c2)
    if d > r1 + r2 or d < abs(r1 - r2) or d == 0:
        return []
    a = (r1 * r1 - r2 * r2 + d * d) / (2.0 * d)
    h_sq = r1 * r1 - a * a
    if h_sq < 0 and abs(h_sq) < 1e-12:
        h_sq = 0.0
    if h_sq < 0:
        return []
    h = math.sqrt(h_sq)
    mid = _add(c1, _scale(_sub(c2, c1), a / d))
    dx, dy = c2[0] - c1[0], c2[1] - c1[1]
    rx, ry = -dy * (h / d), dx * (h / d)
    return [(mid[0] + rx, mid[1] + ry), (mid[0] - rx, mid[1] - ry)]


def distance_point_edge(p: Point, a: Point, b: Point) -> float:
    """Shortest distance from point ``p`` to segment ``ab``."""
    ab = _sub(b, a)
    t = _dot(_sub(p, a), ab) / _dot(ab, ab)
    t = max(0.0, min(1.0, t))
    proj = _add(a, _scale(ab, t))
    return _dist(p, proj)


def circle_arc_polyline(
    center: Point,
    radius: float,
    theta0_deg: float,
    dtheta_deg: float,
    n: int,
) -> list[Point]:
    """Sample an arc; angles in degrees (geom2d ``circleArcToPolyline``)."""
    t0 = math.radians(theta0_deg)
    t1 = t0 + math.radians(dtheta_deg)
    if n < 2:
        n = 2
    return [
        (
            center[0] + radius * math.cos(t0 + (t1 - t0) * i / (n - 1)),
            center[1] + radius * math.sin(t0 + (t1 - t0) * i / (n - 1)),
        )
        for i in range(n)
    ]


def circle_polygon(center: Point, radius: float, n: int) -> list[Point]:
    """Closed polygon with ``n+1`` vertices (last equals first), like geom2d."""
    pts = [
        (
            center[0] + radius * math.cos(2.0 * math.pi * i / n),
            center[1] + radius * math.sin(2.0 * math.pi * i / n),
        )
        for i in range(n)
    ]
    pts.append(pts[0])
    return pts


# Flag construction
@dataclass
class FlagGeometry:
    """All construction points, arcs, and derived polygons for one base length."""

    base_length: float
    points: dict[str, Point] = field(default_factory=dict)
    border: list[Point] = field(default_factory=list)
    inner: list[Point] = field(default_factory=list)
    moon_polygon: list[Point] = field(default_factory=list)
    sun_polygon: list[Point] = field(default_factory=list)
    moon_rays: list[tuple[Point, Point]] = field(default_factory=list)
    sun_rays: list[tuple[Point, Point]] = field(default_factory=list)
    imaginary_edges: list[tuple[Point, Point]] = field(default_factory=list)
    arcs: dict[str, tuple[Point, float, float, float]] = field(default_factory=dict)
    circles: dict[str, tuple[Point, float]] = field(default_factory=dict)
    border_width: float = 0.0

    @property
    def bounds(self) -> tuple[float, float, float, float]:
        xs: list[float] = []
        ys: list[float] = []
        for poly in (self.border, self.inner, self.moon_polygon, self.sun_polygon):
            for x, y in poly:
                xs.append(x)
                ys.append(y)
        for p in self.points.values():
            xs.append(p[0])
            ys.append(p[1])
        pad = self.border_width * 0.5 if self.border_width else self.base_length * 0.02
        return (min(xs) - pad, min(ys) - pad, max(xs) + pad, max(ys) + pad)


def construct_flag(base_length: float = 800.0) -> FlagGeometry:
    """Build flag geometry from base length AB (only free parameter)."""
    logger.info("Constructing flag geometry with base_length=%.3f", base_length)
    b = float(base_length)
    x0, y0 = 0.0, 0.0

    # (A) Shape inside the border
    A = (x0, y0)
    B = (x0 + b, y0)
    C = (x0, y0 + b + b / 3.0)
    D = (x0, y0 + b)

    # (3) E on BD with BE = AB
    pts = intersect_line_circle(B, _sub(D, B), B, b)
    E = pts[1]  # geom2d second intersection (toward D)

    F = (x0, E[1])
    G = (x0 + b, E[1])

    # (B) Moon
    H = (b / 4.0, A[1])
    I = intersect_edges(H, (H[0], C[1]), C, G)

    J = _mid(C, F)
    K = intersect_edges(J, (J[0] + b, J[1]), C, G)
    L = intersect_edges(J, K, H, I)
    M = intersect_edges(J, G, H, I)

    dist_m_bd = distance_point_edge(M, B, D)
    N = (M[0], M[1] - dist_m_bd)

    O = (A[0], M[1])
    O1 = intersect_edges(O, M, C, G)

    radius_l = _dist(L, N)
    pq = intersect_line_circle(O, _sub(M, O), L, radius_l)
    P, Q = pq[0], pq[1]

    radius_m = _dist(M, Q)
    radius_n = _dist(N, M)
    rs = intersect_circles(L, radius_l, N, radius_n)
    # geom2d: first point R, second S (left/right of HI)
    if rs[0][0] <= rs[1][0]:
        R, S = rs[0], rs[1]
    else:
        R, S = rs[1], rs[0]

    T = intersect_edges(R, S, H, I)
    radius_tu = _dist(T, S)
    radius_tl = _dist(T, M)

    xu = circle_arc_polyline(T, radius_tu, 180.0, -180.0, 38)
    xl = circle_arc_polyline(T, radius_tl, 195.0, -210.0, 11)

    # Moon ray segments (MATLAB 1-based indices → Python 0-based)
    moon_ray_pairs = [
        (xu[0], xl[1]),
        (xu[-1], xl[-2]),
        (xl[1], xu[4]),
        (xu[4], xl[2]),
        (xl[-2], xu[-5]),
        (xu[-5], xl[-3]),
        (xl[2], xu[8]),
        (xu[8], xl[3]),
        (xl[-3], xu[-9]),
        (xu[-9], xl[-4]),
        (xl[3], xu[12]),
        (xu[12], xl[4]),
        (xl[-4], xu[-13]),
        (xu[-13], xl[-5]),
        (xl[4], xu[16]),
        (xu[16], xl[5]),
        (xl[-5], xu[-17]),
        (xu[-17], xl[-6]),
    ]

    # (C) Sun
    U = _mid(A, F)
    V = intersect_edges(U, (U[0] + b, U[1]), B, E)
    W = intersect_edges(U, V, H, I)

    radius_wi = _dist(M, N)  # inner sun circle
    radius_wo = _dist(L, N)  # outer sun circle
    pi_pts = circle_polygon(W, radius_wi, 24)  # 25 pts, MATLAB 1..25
    po_pts = circle_polygon(W, radius_wo, 48)  # 49 pts

    # MATLAB PI(i)/PO(j) are 1-based; convert to 0-based.
    sun_ray_pairs = [
        (pi_pts[1], po_pts[0]),
        (pi_pts[1], po_pts[4]),
        (po_pts[4], pi_pts[3]),
        (pi_pts[3], po_pts[8]),
        (po_pts[8], pi_pts[5]),
        (pi_pts[5], po_pts[12]),
        (po_pts[12], pi_pts[7]),
        (pi_pts[7], po_pts[16]),
        (po_pts[16], pi_pts[9]),
        (pi_pts[9], po_pts[20]),
        (po_pts[20], pi_pts[11]),
        (pi_pts[11], po_pts[24]),
        (po_pts[24], pi_pts[13]),
        (pi_pts[13], po_pts[28]),
        (po_pts[28], pi_pts[15]),
        (pi_pts[15], po_pts[32]),
        (po_pts[32], pi_pts[17]),
        (pi_pts[17], po_pts[36]),
        (po_pts[36], pi_pts[19]),
        (pi_pts[19], po_pts[40]),
        (po_pts[40], pi_pts[21]),
        (pi_pts[21], po_pts[44]),
        (po_pts[44], pi_pts[23]),
        (pi_pts[23], po_pts[0]),
    ]

    sun_polygon = [
        pi_pts[1],
        po_pts[4],
        pi_pts[3],
        po_pts[8],
        pi_pts[5],
        po_pts[12],
        pi_pts[7],
        po_pts[16],
        pi_pts[9],
        po_pts[20],
        pi_pts[11],
        po_pts[24],
        pi_pts[13],
        po_pts[28],
        pi_pts[15],
        po_pts[32],
        pi_pts[17],
        po_pts[36],
        pi_pts[19],
        po_pts[40],
        pi_pts[21],
        po_pts[44],
        pi_pts[23],
        po_pts[0],
    ]

    # Moon filled outline (crescent + eight rays), matching MATLAB fillcolor path
    arc_pqu = circle_arc_polyline(L, radius_l, -159.0, 138.0, 65)
    arc_pql = circle_arc_polyline(M, radius_m, -180.0, 180.0, 65)

    m_crisp_l = [
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
    ]
    m_crisp_r = [
        xu[-1],
        xl[-2],
        xu[-5],
        xl[-3],
        xu[-9],
        xl[-4],
        xu[-13],
        xl[-5],
        xu[-17],
        xl[-6],
    ]

    left_arc = [(x, y) for x, y in arc_pqu if x <= R[0]]
    right_arc = [(x, y) for x, y in arc_pqu if x >= S[0]]
    moon_polygon = (
        left_arc
        + m_crisp_l
        + list(reversed(m_crisp_r))
        + right_arc
        + list(reversed(arc_pql))
    )

    # (D) Border width = TN
    border_width = _dist(T, N)
    ab_b = parallel_edge(A, B, border_width)
    ac_b = parallel_edge(A, C, -border_width)
    cg_b = parallel_edge(C, G, -border_width)
    eg_b = parallel_edge(E, G, border_width)
    be_b = parallel_edge(B, E, border_width)

    a_bi = intersect_lines(
        ab_b[0], _sub(ab_b[1], ab_b[0]), ac_b[0], _sub(ac_b[1], ac_b[0])
    )
    c_bi = intersect_lines(
        ac_b[0], _sub(ac_b[1], ac_b[0]), cg_b[0], _sub(cg_b[1], cg_b[0])
    )
    g_bi = intersect_lines(
        cg_b[0], _sub(cg_b[1], cg_b[0]), eg_b[0], _sub(eg_b[1], eg_b[0])
    )
    e_bi = intersect_lines(
        eg_b[0], _sub(eg_b[1], eg_b[0]), be_b[0], _sub(be_b[1], be_b[0])
    )
    b_bi = intersect_lines(
        ab_b[0], _sub(ab_b[1], ab_b[0]), be_b[0], _sub(be_b[1], be_b[0])
    )

    inner = [A, B, E, G, C]
    border = [a_bi, b_bi, e_bi, g_bi, c_bi]

    points = {
        "A": A,
        "B": B,
        "C": C,
        "D": D,
        "E": E,
        "F": F,
        "G": G,
        "H": H,
        "I": I,
        "J": J,
        "K": K,
        "L": L,
        "M": M,
        "N": N,
        "O": O,
        "O1": O1,
        "P": P,
        "Q": Q,
        "R": R,
        "S": S,
        "T": T,
        "U": U,
        "V": V,
        "W": W,
    }

    imaginary_edges = [
        (H, I),
        (J, K),
        (J, G),
        (O, O1),
        (R, S),
        (F, G),
        (U, V),
        (B, D),
    ]

    arcs = {
        "crescent_outer": (L, radius_l, -159.0, 138.0),
        "crescent_inner": (M, radius_m, -180.0, 180.0),
        "moon_upper": (T, radius_tu, 180.0, -180.0),
        "moon_lower": (T, radius_tl, 195.0, -210.0),
        "n_arc": (N, radius_n, 180.0, -180.0),
    }
    circles = {
        "sun_inner": (W, radius_wi),
        "sun_outer": (W, radius_wo),
    }

    logger.debug(
        "Border width=%.4f, points=%d, moon_pts=%d, sun_pts=%d",
        border_width,
        len(points),
        len(moon_polygon),
        len(sun_polygon),
    )

    return FlagGeometry(
        base_length=b,
        points=points,
        border=border,
        inner=inner,
        moon_polygon=moon_polygon,
        sun_polygon=sun_polygon,
        moon_rays=moon_ray_pairs,
        sun_rays=sun_ray_pairs,
        imaginary_edges=imaginary_edges,
        arcs=arcs,
        circles=circles,
        border_width=border_width,
    )


def iter_labeled_points(geom: FlagGeometry, mode: str) -> Iterable[tuple[str, Point]]:
    """Yield landmark labels for ``landmark`` mode (full construction view)."""
    if mode != "landmark":
        return
    skip = {"O1"}
    for name, pt in sorted(geom.points.items()):
        if name not in skip:
            yield name, pt
