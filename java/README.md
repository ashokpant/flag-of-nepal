# National Flag of Nepal (Java)

Pure Java construction of Nepal's national flag from the constitutional
geometry (Schedule 1, Article 8). No dependencies.

## Setup

JDK 11+.

```bash
cd java
make build
```

## Usage

```bash
make run              # base 800 → output/
make run BASE=920
make clean
```

Or directly:

```bash
javac FlagOfNepal.java
java FlagOfNepal [baseLength] [outputDir]
```

Writes:

- `np_flag_color.svg`
- `np_flag_skeleton.svg`
- `np_flag_landmark.svg`
- `np_flag.html` (all three modes)

### Modes

| Mode | Description |
|------|-------------|
| `color` | Final coloured flag |
| `skeleton` | Wireframe outline |
| `landmark` | Labels and imaginary construction lines |
