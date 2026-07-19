"""
Author: Ashok Kumar Pant <asokpant@gmail.com>
Date: July 19, 2026
"""

from .geometry import FlagGeometry, construct_flag
from .render import build_all, export_flag, render_html, render_svg

__all__ = [
    "FlagGeometry",
    "construct_flag",
    "export_flag",
    "build_all",
    "render_svg",
    "render_html",
]

__version__ = "1.0.0"
