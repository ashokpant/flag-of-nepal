# National Flag of Nepal (MATLAB)

Pure MATLAB construction of Nepal's national flag from the constitutional
geometry (Schedule 1, Article 8).

**No toolboxes required.** The old `geom2d` dependency is not used.

## Setup

```matlab
cd matlab
% or add the matlab/ folder to the MATLAB path
addpath(pwd)
```

## Usage

```matlab
flagOfNepal                 % colour flag (default)
flagOfNepal(920)
flagOfNepal(920, 'color')
flagOfNepal(920, 'skeleton')
flagOfNepal(920, 'landmark')
```

### Modes

| Mode | Description |
|------|-------------|
| `color` | Final coloured flag (default) |
| `skeleton` | Wireframe outline |
| `landmark` | Construction points, labels, and imaginary lines/arcs |

Legacy names (`fillcolor`, `landmarks`, `alldrawings`) still map to the modes above.

## Layout

```
matlab/
  flagOfNepal.m   % construction + drawing (self-contained)
  README.md
```
