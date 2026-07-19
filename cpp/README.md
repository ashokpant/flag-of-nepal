# National Flag of Nepal (C++)

The most mathematical flag in the world.

Constitution of Nepal, Schedule 1, Article 8.

## Setup

C++17 and CMake 3.16+.

```bash
cd cpp
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
cmake -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build
./build/flag-of-nepal [baseLength] [outputDir]
```

Writes `np_flag_color.svg`, `np_flag_skeleton.svg`, `np_flag_landmark.svg`, and `np_flag.html`.

### Modes

| Mode | Description |
|------|-------------|
| `color` | Final coloured flag |
| `skeleton` | Wireframe outline |
| `landmark` | Labels and imaginary construction lines |
