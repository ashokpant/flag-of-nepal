# National Flag of Nepal (Rust)

Pure Rust construction of Nepal's national flag from the constitutional geometry (Schedule 1, Article 8).

## Setup

Rust 1.70+ (cargo).

```bash
cd rust
make run
```

## Usage

```bash
make run              # base 800 → output/
make run BASE=920
make build            # release binary
make clean
```

Or:

```bash
cargo run -- [baseLength] [outputDir]
```

Writes:

- `np_flag_color.svg`
- `np_flag_skeleton.svg`
- `np_flag_landmark.svg`
- `np_flag.html`

### Modes

| Mode       | Description                             |
| ---------- | --------------------------------------- |
| `color`    | Final coloured flag                     |
| `skeleton` | Wireframe outline                       |
| `landmark` | Labels and imaginary construction lines |
