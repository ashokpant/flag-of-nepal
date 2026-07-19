# National Flag of Nepal (JavaScript)

The most mathematical flag in the world.

Constitution of Nepal, Schedule 1, Article 8.

## Setup

Node.js 18+.

```bash
cd javascript
make run
```

## Usage

```bash
make run
make run BASE=920
make clean
```

```bash
node bin/flag-of-nepal.mjs [baseLength] [outputDir]
```

```javascript
import { construct, toSVG, toHTML, MODES } from "npflag";
```

Writes `np_flag_color.svg`, `np_flag_skeleton.svg`, `np_flag_landmark.svg`, and `np_flag.html`.

### Modes

| Mode | Description |
|------|-------------|
| `color` | Final coloured flag |
| `skeleton` | Wireframe outline |
| `landmark` | Labels and imaginary construction lines |
