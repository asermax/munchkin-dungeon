---
name: isometric-grid
description: Reference for the isometric grid system. Use when working with grid coordinates, height maps, tile rendering, click detection, pathfinding, or movement range.
---

# Isometric Grid Reference

## Constants

```
TILE_WIDTH = 64, TILE_HEIGHT = 32 (2:1 diamond ratio)
TILE_HALF_WIDTH = 32, TILE_HALF_HEIGHT = 16
HEIGHT_OFFSET = 16 (per height level, moves tile up)
Grid: 8x8 (configurable via @export), heights 0-4
```

## Coordinate Conversion

Grid <-> world (manual math, no TileMapLayer):

```gdscript
func grid_to_world(cell: Vector2i) -> Vector2:
    var x := (cell.x - cell.y) * TILE_HALF_WIDTH
    var y := (cell.x + cell.y) * TILE_HALF_HEIGHT
    return Vector2(x, y)

func world_to_grid(world_pos: Vector2) -> Vector2i:
    var col := (world_pos.x / TILE_HALF_WIDTH + world_pos.y / TILE_HALF_HEIGHT) / 2.0
    var row := (world_pos.y / TILE_HALF_HEIGHT - world_pos.x / TILE_HALF_WIDTH) / 2.0
    return Vector2i(floori(col), floori(row))
```

With height: `pos.y -= height * HEIGHT_OFFSET` on top of the base conversion.

## Height-Aware Click Detection

Check from highest elevation down — a click at screen position might hit a tall tile above a short one:

```gdscript
func world_to_grid_elevated(world_pos: Vector2) -> Vector2i:
    for h in range(max_height, -1, -1):
        var test_pos := world_pos
        test_pos.y += h * HEIGHT_OFFSET
        var cell := world_to_grid(test_pos)
        if is_valid_cell(cell) and height_map.get(cell, 0) == h:
            return cell
    return world_to_grid(world_pos)
```

## Placeholder Art via _draw()

Isometric diamond polygon (4 points):
```gdscript
var points := PackedVector2Array([
    center + Vector2(0, -TILE_HALF_HEIGHT),        # top
    center + Vector2(TILE_HALF_WIDTH, 0),           # right
    center + Vector2(0, TILE_HALF_HEIGHT),           # bottom
    center + Vector2(-TILE_HALF_WIDTH, 0),           # left
])
draw_colored_polygon(points, color)
```

Side faces for elevated tiles: right face and left face using offset by `h * HEIGHT_OFFSET`.

## Pathfinder (TODO)

- AStarGrid2D wrapper
- `diagonal_mode = NEVER` (4-directional)
- Height diff > 1 = impassable, diff == 1 = weight 2.0
- `default_compute_heuristic = HEURISTIC_MANHATTAN`
- Flood-fill for movement range returns `Dictionary[Vector2i, float]` (cell -> cost)

## Key Files

- `scripts/grid/grid_manager.gd` — GridManager class, coordinate conversion, height_map, rendering
- `scripts/grid/click_handler.gd` — ClickHandler, height-aware click → EventBus.tile_clicked
