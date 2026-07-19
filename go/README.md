# National Flag of Nepal (Go)

Pure Go construction of Nepal's national flag from the constitutional geometry (Schedule 1, Article 8). 

## Setup

Go 1.18+.

```bash
cd go
make run
```

## Usage

```bash
make run              # base 800 → output/
make run BASE=920
make build            # compile to bin/flag-of-nepal
make clean
```

Or:

```bash
go run . [baseLength] [outputDir]
```

Writes:

- `np_flag_color.svg`
- `np_flag_skeleton.svg`
- `np_flag_landmark.svg`
- `np_flag.html`

### Modes

| Mode | Description |
|------|-------------|
| `color` | Final coloured flag |
| `skeleton` | Wireframe outline |
| `landmark` | Labels and imaginary construction lines |
