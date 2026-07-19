# National Flag of Nepal (Python)

The most mathematical flag in the world.

Constitution of Nepal, Schedule 1, Article 8.

## Setup

```bash
cd python
make install
```

## Usage

```bash
make run
make flag MODE=landmark
make html
make upgrade
make clean
```

```bash
uv run flag-of-nepal build -b 800 -o output
uv run flag-of-nepal export -m color -f svg -o output/np_flag_color
```

### Modes

| Mode | Description |
|------|-------------|
| `color` | Final coloured flag |
| `skeleton` | Wireframe outline |
| `landmark` | Labels and imaginary construction lines |
