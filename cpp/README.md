# National Flag of Nepal (C++)

Pure C++17 construction of Nepal's national flag from the constitutional geometry (Schedule 1, Article 8).

## Setup

C++17 compiler (g++ or clang++).

```bash
cd cpp
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
./bin/flag-of-nepal [baseLength] [outputDir]
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
