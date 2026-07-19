# National Flag of Nepal (Java)

The most mathematical flag in the world.

Constitution of Nepal, Schedule 1, Article 8.

## Setup

JDK 11+.

```bash
cd java
make build
```

## Usage

```bash
make run
make run BASE=920
make clean
```

```bash
javac -d out src/main/java/flagofnepal/FlagOfNepal.java
java -cp out flagofnepal.FlagOfNepal [baseLength] [outputDir]
```

Writes `np_flag_color.svg`, `np_flag_skeleton.svg`, `np_flag_landmark.svg`, and `np_flag.html`.

### Modes

| Mode | Description |
|------|-------------|
| `color` | Final coloured flag |
| `skeleton` | Wireframe outline |
| `landmark` | Labels and imaginary construction lines |
