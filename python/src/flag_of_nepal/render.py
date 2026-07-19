from __future__ import annotations

import logging
from pathlib import Path
from xml.sax.saxutils import escape

from .geometry import (
    FlagGeometry,
    circle_arc_polyline,
    construct_flag,
    iter_labeled_points,
)

logger = logging.getLogger(__name__)

CRIMSON = "#DC143C"
DEEP_BLUE = "#003893"
WHITE = "#FFFFFF"
INK = "#111111"
IMAGINARY = "#888888"

MODES = ("color", "skeleton", "landmark")
FORMATS = ("svg", "image", "html")

MODE_TITLES = {
    "color": "Colour flag",
    "skeleton": "Skeleton",
    "landmark": "Landmarks",
}


def _poly_points(pts: list[tuple[float, float]], flip_y: float) -> str:
    return " ".join(f"{x:.4f},{flip_y - y:.4f}" for x, y in pts)


def _edge(
    a: tuple[float, float],
    b: tuple[float, float],
    flip_y: float,
    color: str = INK,
    width: float = 1.5,
    dash: str | None = None,
) -> str:
    dash_attr = f' stroke-dasharray="{dash}"' if dash else ""
    return (
        f'<line x1="{a[0]:.4f}" y1="{flip_y - a[1]:.4f}" '
        f'x2="{b[0]:.4f}" y2="{flip_y - b[1]:.4f}" '
        f'stroke="{color}" stroke-width="{width}"{dash_attr} />'
    )


def _arc_path(
    center: tuple[float, float],
    radius: float,
    theta0: float,
    dtheta: float,
    flip_y: float,
    n: int = 64,
) -> str:
    pts = circle_arc_polyline(center, radius, theta0, dtheta, n)
    if not pts:
        return ""
    cmds = [f"M {pts[0][0]:.4f},{flip_y - pts[0][1]:.4f}"]
    for x, y in pts[1:]:
        cmds.append(f"L {x:.4f},{flip_y - y:.4f}")
    return " ".join(cmds)


def _inline_svg(svg: str) -> str:
    """Strip XML declaration for embedding in HTML."""
    if svg.startswith("<?xml"):
        return svg.split("\n", 1)[1]
    return svg


def render_svg(geom: FlagGeometry, mode: str = "color") -> str:
    """Return an SVG document string for the given drawing mode."""
    if mode not in MODES:
        raise ValueError(f"unknown mode {mode!r}; choose from {MODES}")

    min_x, min_y, max_x, max_y = geom.bounds
    width = max_x - min_x
    height = max_y - min_y
    flip = max_y
    parts: list[str] = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        f'<svg xmlns="http://www.w3.org/2000/svg" '
        f'viewBox="{min_x:.4f} {0:.4f} {width:.4f} {height:.4f}" '
        f'width="{width:.0f}" height="{height:.0f}" '
        f'role="img" aria-label="National Flag of Nepal">',
        f"<title>National Flag of Nepal ({mode})</title>",
    ]

    def edge(a, b, color=INK, width=1.5, dash=None):
        parts.append(_edge(a, b, flip, color, width, dash))

    def label(name, pt):
        parts.append(
            f'<text x="{pt[0] + 6:.4f}" y="{flip - pt[1] - 6:.4f}" '
            f'font-family="Helvetica, Arial, sans-serif" '
            f'font-size="{geom.base_length * 0.035:.1f}" '
            f'fill="{INK}">{escape(name)}</text>'
        )

    if mode == "color":
        parts.append(
            f'<polygon points="{_poly_points(geom.border + [geom.border[0]], flip)}" '
            f'fill="{DEEP_BLUE}" stroke="none" />'
        )
        parts.append(
            f'<polygon points="{_poly_points(geom.inner + [geom.inner[0]], flip)}" '
            f'fill="{CRIMSON}" stroke="none" />'
        )
        parts.append(
            f'<polygon points="{_poly_points(geom.moon_polygon, flip)}" '
            f'fill="{WHITE}" stroke="none" />'
        )
        parts.append(
            f'<polygon points="{_poly_points(geom.sun_polygon + [geom.sun_polygon[0]], flip)}" '
            f'fill="{WHITE}" stroke="none" />'
        )
    else:
        p = geom.points
        edge(p["A"], p["B"])
        edge(p["A"], p["C"])
        edge(p["E"], p["G"])
        edge(p["C"], p["G"])
        edge(p["B"], p["E"])
        for a, b in zip(geom.border, geom.border[1:] + geom.border[:1]):
            edge(a, b)

        for key in ("crescent_outer", "crescent_inner", "moon_lower"):
            c, r, t0, dt = geom.arcs[key]
            d = _arc_path(c, r, t0, dt, flip)
            parts.append(
                f'<path d="{d}" fill="none" stroke="{INK}" stroke-width="1.5" />'
            )

        for a, b in geom.moon_rays:
            edge(a, b)
        for a, b in geom.sun_rays:
            edge(a, b)

        c, r = geom.circles["sun_inner"]
        parts.append(
            f'<circle cx="{c[0]:.4f}" cy="{flip - c[1]:.4f}" r="{r:.4f}" '
            f'fill="none" stroke="{INK}" stroke-width="1.5" />'
        )

        if mode == "landmark":
            for name, pt in iter_labeled_points(geom, mode):
                parts.append(
                    f'<circle cx="{pt[0]:.4f}" cy="{flip - pt[1]:.4f}" r="3" fill="{INK}" />'
                )
                label(name, pt)

            c, r, t0, dt = geom.arcs["moon_upper"]
            d = _arc_path(c, r, t0, dt, flip)
            parts.append(
                f'<path d="{d}" fill="none" stroke="{IMAGINARY}" '
                f'stroke-width="1" stroke-dasharray="6 4" />'
            )
            c, r, t0, dt = geom.arcs["n_arc"]
            d = _arc_path(c, r, t0, dt, flip)
            parts.append(
                f'<path d="{d}" fill="none" stroke="{IMAGINARY}" '
                f'stroke-width="1" stroke-dasharray="6 4" />'
            )
            c, r = geom.circles["sun_outer"]
            parts.append(
                f'<circle cx="{c[0]:.4f}" cy="{flip - c[1]:.4f}" r="{r:.4f}" '
                f'fill="none" stroke="{IMAGINARY}" stroke-width="1" '
                f'stroke-dasharray="6 4" />'
            )
            for a, b in geom.imaginary_edges:
                edge(a, b, color=IMAGINARY, width=1.0, dash="6 4")

    parts.append("</svg>")
    return "\n".join(parts)


def render_html(geom: FlagGeometry, mode: str = "color") -> str:
    """Static HTML page embedding every drawing mode (mode arg unused)."""
    _ = mode  # single page always includes all modes
    sections: list[str] = []
    for m in MODES:
        svg = _inline_svg(render_svg(geom, m))
        sections.append(
            f'    <section class="flag">\n'
            f"      <h2>{escape(MODE_TITLES[m])}</h2>\n"
            f"{svg}\n"
            f"    </section>"
        )

    body = "\n\n".join(sections)
    return f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>National Flag of Nepal</title>
  <style>
    body {{
      margin: 0;
      font-family: Georgia, "Times New Roman", serif;
      background: #f6f4f1;
      color: #1a1a1a;
    }}
    main {{ max-width: 900px; margin: 2rem auto; padding: 0 1.25rem 3rem; }}
    h1 {{ font-weight: 400; letter-spacing: 0.02em; margin-bottom: 0.35rem; }}
    .meta {{ color: #555; margin: 0 0 2rem; }}
    .flag {{
      background: #fff;
      padding: 1.25rem 1.5rem 1.75rem;
      margin-bottom: 1.5rem;
    }}
    .flag h2 {{
      font-weight: 400;
      font-size: 1.15rem;
      margin: 0 0 1rem;
    }}
    .flag svg {{ width: 100%; height: auto; display: block; }}
  </style>
</head>
<body>
  <main>
    <h1>National Flag of Nepal</h1>
    <p class="meta">
      Base length AB = {geom.base_length:.0f} ·
      Border width TN = {geom.border_width:.4f} ·
      Constitution of Nepal, Schedule 1, Article 8
    </p>
{body}
  </main>
</body>
</html>
"""


def export_flag(
    output: str | Path,
    base_length: float = 800.0,
    mode: str = "color",
    fmt: str = "svg",
) -> Path:
    """Construct the flag and write SVG image or multi-mode HTML."""
    fmt = fmt.lower()
    if fmt == "image":
        fmt = "svg"
    if fmt not in ("svg", "html"):
        raise ValueError(f"unknown format {fmt!r}; choose from {FORMATS}")
    if mode not in MODES:
        raise ValueError(f"unknown mode {mode!r}; choose from {MODES}")

    out = Path(output)
    if out.suffix == "":
        out = out.with_suffix(f".{fmt}")
    out.parent.mkdir(parents=True, exist_ok=True)

    logger.info("Exporting mode=%s format=%s → %s", mode, fmt, out)
    geom = construct_flag(base_length)

    if fmt == "svg":
        text = render_svg(geom, mode)
    else:
        text = render_html(geom, mode)

    out.write_text(text, encoding="utf-8")
    logger.info("Wrote %s (%d bytes)", out, out.stat().st_size)
    return out


def build_all(
    output_dir: str | Path = "output",
    base_length: float = 800.0,
    prefix: str = "np_flag",
) -> list[Path]:
    """Write every mode SVG plus the multi-mode HTML under ``output_dir``."""
    out_dir = Path(output_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    written: list[Path] = []
    for mode in MODES:
        written.append(
            export_flag(
                output=out_dir / f"{prefix}_{mode}",
                base_length=base_length,
                mode=mode,
                fmt="svg",
            )
        )
    written.append(
        export_flag(
            output=out_dir / prefix,
            base_length=base_length,
            mode="color",
            fmt="html",
        )
    )
    return written
