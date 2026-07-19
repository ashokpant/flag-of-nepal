"""CLI for constructing and exporting the National Flag of Nepal."""

from __future__ import annotations

import argparse
import logging
import shutil
import subprocess
import sys
from pathlib import Path

from .render import FORMATS, MODES, build_all, export_flag

logger = logging.getLogger(__name__)


def _add_verbose(parser: argparse.ArgumentParser) -> None:
    parser.add_argument(
        "-v",
        "--verbose",
        action="count",
        default=0,
        help="Increase log verbosity (-v, -vv)",
    )


def _configure_logging(verbose: int) -> None:
    level = logging.WARNING
    if verbose == 1:
        level = logging.INFO
    elif verbose >= 2:
        level = logging.DEBUG
    logging.basicConfig(
        level=level,
        format="%(asctime)s %(levelname)s [%(name)s] %(message)s",
        datefmt="%H:%M:%S",
    )


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="flag-of-nepal",
        description=(
            "Construct the National Flag of Nepal from its constitutional "
            "geometry and export as SVG image or a static HTML page."
        ),
    )
    sub = parser.add_subparsers(dest="command")

    # export (also the default when no subcommand is given)
    export_p = sub.add_parser(
        "export",
        help="Export a single SVG or HTML file",
    )
    export_p.add_argument(
        "-b",
        "--base-length",
        type=float,
        default=800.0,
        help="Length of base AB (default: 800)",
    )
    export_p.add_argument(
        "-m",
        "--mode",
        choices=MODES,
        default="color",
        help="Drawing mode for SVG (ignored for HTML)",
    )
    export_p.add_argument(
        "-f",
        "--format",
        choices=FORMATS,
        default="svg",
        dest="fmt",
        help="Output format: svg/image or html",
    )
    export_p.add_argument(
        "-o",
        "--output",
        default="output/np_flag",
        help="Output path (extension added if omitted)",
    )
    _add_verbose(export_p)

    # build — all assets
    build_p = sub.add_parser(
        "build",
        help="Build all mode SVGs and the multi-mode HTML",
    )
    build_p.add_argument(
        "-b",
        "--base-length",
        type=float,
        default=800.0,
        help="Length of base AB (default: 800)",
    )
    build_p.add_argument(
        "-o",
        "--output-dir",
        default="output",
        help="Output directory (default: output)",
    )
    build_p.add_argument(
        "--prefix",
        default="np_flag",
        help="Filename prefix (default: np_flag)",
    )
    _add_verbose(build_p)

    # upgrade — refresh uv lock + sync
    upgrade_p = sub.add_parser(
        "upgrade",
        help="Upgrade the uv lockfile and re-sync the environment",
    )
    _add_verbose(upgrade_p)

    return parser


def _cmd_export(args: argparse.Namespace) -> int:
    output = args.output
    if args.fmt in ("svg", "image") and output == "output/np_flag":
        output = f"output/np_flag_{args.mode}"

    path = export_flag(
        output=output,
        base_length=args.base_length,
        mode=args.mode,
        fmt=args.fmt,
    )
    print(path)
    return 0


def _cmd_build(args: argparse.Namespace) -> int:
    paths = build_all(
        output_dir=args.output_dir,
        base_length=args.base_length,
        prefix=args.prefix,
    )
    for path in paths:
        print(path)
    logger.info("Built %d file(s) under %s", len(paths), args.output_dir)
    return 0


def _cmd_upgrade(args: argparse.Namespace) -> int:
    uv = shutil.which("uv")
    if not uv:
        logger.error("uv not found on PATH; install uv first")
        return 1

    # Run from the python/ project root (parent of src/).
    project_root = Path(__file__).resolve().parents[2]
    logger.info("Upgrading lockfile in %s", project_root)
    lock = subprocess.run(
        [uv, "lock", "--upgrade"],
        cwd=project_root,
        check=False,
    )
    if lock.returncode != 0:
        return lock.returncode
    sync = subprocess.run(
        [uv, "sync"],
        cwd=project_root,
        check=False,
    )
    return sync.returncode


def main(argv: list[str] | None = None) -> int:
    raw = list(sys.argv[1:] if argv is None else argv)

    # Default to `export` so existing flat flags keep working:
    #   flag-of-nepal -m color -f svg
    known = {"export", "build", "upgrade", "-h", "--help"}
    if not raw or raw[0] not in known:
        raw = ["export", *raw]

    parser = _build_parser()
    args = parser.parse_args(raw)
    _configure_logging(getattr(args, "verbose", 0))

    try:
        if args.command == "build":
            return _cmd_build(args)
        if args.command == "upgrade":
            return _cmd_upgrade(args)
        return _cmd_export(args)
    except Exception as exc:  # noqa: BLE001 — CLI top-level handler
        logger.error("%s", exc)
        return 1


if __name__ == "__main__":
    sys.exit(main())
