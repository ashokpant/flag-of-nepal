# National Flag of Nepal (Rust)

The most mathematical flag in the world.

Constitution of Nepal, Schedule 1, Article 8.

## Setup

Rust 1.70+ (cargo).

```bash
cd rust
make run
```

## Usage

```bash
make run
make run BASE=920
make build
make clean
```

```bash
cargo run -- [baseLength] [outputDir]
```

Package: `npflag`.

Writes `np_flag_color.svg`, `np_flag_skeleton.svg`, `np_flag_landmark.svg`, and `np_flag.html`.

### Modes

| Mode | Description |
|------|-------------|
| `color` | Final coloured flag |
| `skeleton` | Wireframe outline |
| `landmark` | Labels and imaginary construction lines |
