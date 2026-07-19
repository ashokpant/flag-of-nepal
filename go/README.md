# National Flag of Nepal (Go)

The most mathematical flag in the world.

Constitution of Nepal, Schedule 1, Article 8.

## Setup

Go 1.21+.

```bash
cd go
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
go run ./cmd/flag-of-nepal [baseLength] [outputDir]
```

Package: `npflag`.

Writes `np_flag_color.svg`, `np_flag_skeleton.svg`, `np_flag_landmark.svg`, and `np_flag.html`.

### Modes

| Mode | Description |
|------|-------------|
| `color` | Final coloured flag |
| `skeleton` | Wireframe outline |
| `landmark` | Labels and imaginary construction lines |
