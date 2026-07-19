# National Flag of Nepal (Python)

Pure-Python construction of Nepal's national flag from the constitutional
geometry (Schedule 1, Article 8). Zero runtime dependencies.

## Setup

```bash
cd python
make install   # uv sync
```

Requires [uv](https://docs.astral.sh/uv/).

## Usage

```bash
make flag              # one SVG (MODE=color by default)
make flag MODE=landmark
make html              # HTML with all modes
make build             # all SVGs + HTML
make upgrade           # upgrade lockfile + sync
make clean
```

### CLI

```bash
# Export one file (subcommand optional — flat flags still work)
uv run flag-of-nepal export -b 800 -m color -f svg -o output/np_flag_color -v
uv run flag-of-nepal -m landmark -f svg -o output/np_flag_landmark
uv run flag-of-nepal export -f html -o output/np_flag

# Build all assets
uv run flag-of-nepal build -b 800 -o output -v

# Upgrade environment (uv lock --upgrade && uv sync)
uv run flag-of-nepal upgrade -v

uv run flag-of-nepal --help
uv run flag-of-nepal build --help
```

Outputs use the `np_flag_` prefix (`np_flag_color.svg`, `np_flag.html`, …).

### Modes (SVG)

| Mode | Description |
|------|-------------|
| `color` | Final coloured flag (default) |
| `skeleton` | Wireframe outline |
| `landmark` | Construction points, labels, and imaginary lines/arcs |

### Formats

| Format | Output |
|--------|--------|
| `svg` / `image` | Single-mode vector SVG |
| `html` | Static HTML with all three modes embedded |

### Makefile targets

| Target | Description |
|--------|-------------|
| `install` / `sync` | Create/sync the uv environment |
| `flag` | Export one SVG |
| `html` | Export multi-mode HTML |
| `build` / `all` | Build every SVG + HTML |
| `upgrade` | Upgrade lockfile and re-sync |
| `clean` | Remove outputs and local venv |

## Layout

```
python/
  Makefile
  pyproject.toml
  src/flag_of_nepal/
    geometry.py   # constitutional construction
    render.py     # svg + html exporters
    __main__.py   # CLI (export / build / upgrade)
```
