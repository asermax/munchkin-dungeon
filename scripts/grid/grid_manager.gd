class_name GridManager
extends Node2D

const TILE_WIDTH: int = 64
const TILE_HEIGHT: int = 32
const TILE_HALF_WIDTH: float = TILE_WIDTH / 2.0
const TILE_HALF_HEIGHT: float = TILE_HEIGHT / 2.0
const HEIGHT_OFFSET: float = TILE_HALF_HEIGHT

@export var grid_size: Vector2i = Vector2i(8, 8)

var height_map: Dictionary = {}
var unit_map: Dictionary = {}


func _ready() -> void:
	_init_flat_map()


func _draw() -> void:
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var cell := Vector2i(x, y)
			var h: int = height_map.get(cell, 0)
			var world_pos := grid_to_world(cell)

			world_pos.y -= h * HEIGHT_OFFSET

			var color := _height_color(h)
			_draw_isometric_diamond(world_pos, color)

			if h > 0:
				_draw_isometric_sides(world_pos, h, color.darkened(0.3))


func _draw_isometric_diamond(center: Vector2, color: Color) -> void:
	var points := PackedVector2Array([
		center + Vector2(0, -TILE_HALF_HEIGHT),
		center + Vector2(TILE_HALF_WIDTH, 0),
		center + Vector2(0, TILE_HALF_HEIGHT),
		center + Vector2(-TILE_HALF_WIDTH, 0),
	])

	draw_colored_polygon(points, color)
	draw_polyline(points + PackedVector2Array([points[0]]), color.darkened(0.2), 1.0)


func _draw_isometric_sides(top_center: Vector2, h: int, color: Color) -> void:
	var offset := h * HEIGHT_OFFSET

	# Right side
	var right_face := PackedVector2Array([
		top_center + Vector2(TILE_HALF_WIDTH, 0),
		top_center + Vector2(0, TILE_HALF_HEIGHT),
		top_center + Vector2(0, TILE_HALF_HEIGHT + offset),
		top_center + Vector2(TILE_HALF_WIDTH, offset),
	])
	draw_colored_polygon(right_face, color)

	# Left side
	var left_face := PackedVector2Array([
		top_center + Vector2(-TILE_HALF_WIDTH, 0),
		top_center + Vector2(0, TILE_HALF_HEIGHT),
		top_center + Vector2(0, TILE_HALF_HEIGHT + offset),
		top_center + Vector2(-TILE_HALF_WIDTH, offset),
	])
	draw_colored_polygon(left_face, color.darkened(0.15))


func _height_color(h: int) -> Color:
	var base := Color(0.25, 0.35, 0.25)
	return base.lightened(h * 0.15)


## Coordinate conversion: grid cell -> world position (without height offset)
func grid_to_world(cell: Vector2i) -> Vector2:
	var x := (cell.x - cell.y) * TILE_HALF_WIDTH
	var y := (cell.x + cell.y) * TILE_HALF_HEIGHT
	return Vector2(x, y)


## Coordinate conversion: grid cell -> world position (with height offset applied)
func grid_to_world_elevated(cell: Vector2i) -> Vector2:
	var pos := grid_to_world(cell)
	var h: int = height_map.get(cell, 0)
	pos.y -= h * HEIGHT_OFFSET
	return pos


## Coordinate conversion: world position -> grid cell (ignores height)
func world_to_grid(world_pos: Vector2) -> Vector2i:
	var col := (world_pos.x / TILE_HALF_WIDTH + world_pos.y / TILE_HALF_HEIGHT) / 2.0
	var row := (world_pos.y / TILE_HALF_HEIGHT - world_pos.x / TILE_HALF_WIDTH) / 2.0
	return Vector2i(floori(col), floori(row))


## Height-aware click detection: check from highest elevation down
func world_to_grid_elevated(world_pos: Vector2) -> Vector2i:
	var max_h: int = 4

	for h in range(max_h, -1, -1):
		var test_pos := world_pos
		test_pos.y += h * HEIGHT_OFFSET
		var cell := world_to_grid(test_pos)

		if not is_valid_cell(cell):
			continue

		if height_map.get(cell, 0) == h:
			return cell

	return world_to_grid(world_pos)


func is_valid_cell(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < grid_size.x and cell.y >= 0 and cell.y < grid_size.y


func is_cell_occupied(cell: Vector2i) -> bool:
	return unit_map.has(cell)


## Initialize all cells at height 0. Override or extend for custom maps.
func _init_flat_map() -> void:
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			height_map[Vector2i(x, y)] = 0
