class_name DungeonMapUI
extends Control

## Draws the dungeon map as a horizontal bar with rooms connected by right-angle paths.
## Rooms are clickable when available. Branches diverge vertically with L-shaped corridors.
## Uses hand-drawn dungeon icons for room types and stone path texture for corridors.

signal room_clicked(room: RoomData)

const ROOM_SIZE := Vector2(56, 56)
const ROOM_SPACING := 90.0
const BRANCH_OFFSET_Y := 44.0
const PATH_THICKNESS := 16.0
const VERT_PATH_WIDTH := 6.0
const PADDING := Vector2(48, 0)

# State colors
const COLOR_VISITED_MOD := Color(0.4, 0.4, 0.4, 1.0)
const COLOR_CURRENT_GLOW := Color(0.85, 0.65, 0.1, 0.6)
const COLOR_CURRENT_BORDER := Color(0.9, 0.7, 0.15, 0.85)
const COLOR_AVAILABLE_GLOW := Color(0.5, 0.45, 0.3, 0.4)
const COLOR_AVAILABLE_BORDER := Color(0.7, 0.6, 0.35, 0.6)
const COLOR_VERT_PATH := Color(0.45, 0.38, 0.28, 0.8)
const COLOR_VERT_SHADOW := Color(0.15, 0.12, 0.08, 0.5)
const COLOR_VERT_HIGHLIGHT := Color(0.6, 0.5, 0.35, 0.3)
const COLOR_BG := Color(0.08, 0.07, 0.09, 0.95)

# Textures
var _tex_monster: Texture2D = preload("res://assets/map/room_monster.png")
var _tex_boss: Texture2D = preload("res://assets/map/room_boss.png")
var _tex_treasure: Texture2D = preload("res://assets/map/room_treasure.png")
var _tex_rest: Texture2D = preload("res://assets/map/room_rest.png")
var _tex_curse: Texture2D = preload("res://assets/map/room_curse.png")
var _tex_hidden: Texture2D = preload("res://assets/map/room_hidden.png")
var _tex_path: Texture2D = preload("res://assets/map/path_horizontal.png")

var _dungeon: DungeonData
var _room_positions: Dictionary = {}    # room.id -> Vector2 (center)
var _room_rects: Dictionary = {}        # room.id -> Rect2
var _available_rooms: Dictionary = {}   # room.id -> true
var _visited_rooms: Dictionary = {}     # room.id -> true
var _current_room_id: String = ""

# Connection segments stored separately by type for different rendering
var _h_segments: Array[PackedVector2Array] = []  # horizontal: drawn with path texture
var _v_segments: Array[PackedVector2Array] = []  # vertical: drawn with styled lines


func setup(dungeon: DungeonData) -> void:
	_dungeon = dungeon
	_room_positions.clear()
	_room_rects.clear()
	_available_rooms.clear()
	_visited_rooms.clear()
	_current_room_id = ""
	_h_segments.clear()
	_v_segments.clear()

	_calculate_layout()
	queue_redraw()


func set_available_rooms(room_ids: Array[String]) -> void:
	_available_rooms.clear()

	for id: String in room_ids:
		_available_rooms[id] = true

	queue_redraw()


func mark_room_visited(room_id: String) -> void:
	_visited_rooms[room_id] = true
	_available_rooms.erase(room_id)
	queue_redraw()


func set_current_room(room_id: String) -> void:
	_current_room_id = room_id
	queue_redraw()


func reveal_room(room_id: String) -> void:
	queue_redraw()


func _add_h_segment(from: Vector2, to: Vector2) -> void:
	_h_segments.append(PackedVector2Array([from, to]))


func _add_v_segment(from: Vector2, to: Vector2) -> void:
	_v_segments.append(PackedVector2Array([from, to]))


func _calculate_layout() -> void:
	if _dungeon == null:
		return

	var x := PADDING.x + ROOM_SIZE.x / 2.0
	var center_y := size.y / 2.0

	# Track the last connection anchor on the main horizontal line.
	# This is either a room center or a rejoin point from a branch.
	var last_main_pos := Vector2.ZERO

	for seg: DungeonSegmentData in _dungeon.segments:
		if seg.segment_type == "single":
			var pos := Vector2(x, center_y)
			_room_positions[seg.room.id] = pos
			_room_rects[seg.room.id] = Rect2(pos - ROOM_SIZE / 2.0, ROOM_SIZE)

			# Connect from previous main anchor
			if last_main_pos != Vector2.ZERO:
				_add_h_segment(last_main_pos, pos)

			last_main_pos = pos
			x += ROOM_SPACING

		elif seg.segment_type == "branch":
			var split_x := x - ROOM_SPACING / 2.0
			var split_pos := Vector2(split_x, center_y)
			var top_y := center_y - BRANCH_OFFSET_Y
			var bot_y := center_y + BRANCH_OFFSET_Y

			# Connect previous main anchor to the split point
			if last_main_pos != Vector2.ZERO:
				_add_h_segment(last_main_pos, split_pos)

			# Position path A rooms (top)
			for i: int in seg.path_a.size():
				var room: RoomData = seg.path_a[i]
				var pos := Vector2(x + i * ROOM_SPACING, top_y)
				_room_positions[room.id] = pos
				_room_rects[room.id] = Rect2(pos - ROOM_SIZE / 2.0, ROOM_SIZE)

			# Position path B rooms (bottom)
			for i: int in seg.path_b.size():
				var room: RoomData = seg.path_b[i]
				var pos := Vector2(x + i * ROOM_SPACING, bot_y)
				_room_positions[room.id] = pos
				_room_rects[room.id] = Rect2(pos - ROOM_SIZE / 2.0, ROOM_SIZE)

			# Split connections (L-shaped: vertical then horizontal)
			var first_a: Vector2 = _room_positions[seg.path_a[0].id]
			var first_b: Vector2 = _room_positions[seg.path_b[0].id]

			_add_v_segment(split_pos, Vector2(split_x, top_y))
			_add_h_segment(Vector2(split_x, top_y), first_a)

			_add_v_segment(split_pos, Vector2(split_x, bot_y))
			_add_h_segment(Vector2(split_x, bot_y), first_b)

			# Horizontal connections between rooms within each path
			for i: int in range(1, seg.path_a.size()):
				_add_h_segment(
					_room_positions[seg.path_a[i - 1].id],
					_room_positions[seg.path_a[i].id],
				)

			for i: int in range(1, seg.path_b.size()):
				_add_h_segment(
					_room_positions[seg.path_b[i - 1].id],
					_room_positions[seg.path_b[i].id],
				)

			# Advance x past the longer path
			var max_path := maxi(seg.path_a.size(), seg.path_b.size())
			x += max_path * ROOM_SPACING

			# Rejoin connections (L-shaped: horizontal then vertical)
			var rejoin_x := x - ROOM_SPACING / 2.0
			var rejoin_pos := Vector2(rejoin_x, center_y)
			var last_a: Vector2 = _room_positions[seg.path_a[seg.path_a.size() - 1].id]
			var last_b: Vector2 = _room_positions[seg.path_b[seg.path_b.size() - 1].id]

			_add_h_segment(last_a, Vector2(rejoin_x, top_y))
			_add_v_segment(Vector2(rejoin_x, top_y), rejoin_pos)

			_add_h_segment(last_b, Vector2(rejoin_x, bot_y))
			_add_v_segment(Vector2(rejoin_x, bot_y), rejoin_pos)

			last_main_pos = rejoin_pos

	# Set minimum size based on layout
	custom_minimum_size.x = x + PADDING.x


func _draw() -> void:
	_draw_background()

	if _dungeon == null:
		return

	# Recalculate if size changed
	var center_y := size.y / 2.0
	var needs_recalc := false

	for id: String in _room_positions:
		var pos: Vector2 = _room_positions[id]

		if absf(pos.y - center_y) > BRANCH_OFFSET_Y + 10:
			needs_recalc = true
			break

	if needs_recalc:
		_h_segments.clear()
		_v_segments.clear()
		_calculate_layout()

	# Draw horizontal paths with texture
	for seg: PackedVector2Array in _h_segments:
		_draw_h_path(seg[0], seg[1])

	# Draw vertical paths with styled lines
	for seg: PackedVector2Array in _v_segments:
		_draw_v_path(seg[0], seg[1])

	# Draw rooms on top
	for seg: DungeonSegmentData in _dungeon.segments:
		if seg.segment_type == "single":
			_draw_room(seg.room)
		elif seg.segment_type == "branch":
			for room: RoomData in seg.path_a:
				_draw_room(room)
			for room: RoomData in seg.path_b:
				_draw_room(room)


func _draw_background() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), COLOR_BG)

	# Subtle top/bottom edge darkening
	var edge_h := size.y * 0.25

	draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, edge_h)), Color(0.0, 0.0, 0.0, 0.3))
	draw_rect(Rect2(Vector2(0, size.y - edge_h), Vector2(size.x, edge_h)), Color(0.0, 0.0, 0.0, 0.3))


func _draw_h_path(from: Vector2, to: Vector2) -> void:
	# Horizontal corridor using the path texture
	var left_x := minf(from.x, to.x)
	var right_x := maxf(from.x, to.x)
	var mid_y := (from.y + to.y) / 2.0

	var rect := Rect2(
		Vector2(left_x, mid_y - PATH_THICKNESS / 2.0),
		Vector2(right_x - left_x, PATH_THICKNESS),
	)

	draw_texture_rect(_tex_path, rect, false)


func _draw_v_path(from: Vector2, to: Vector2) -> void:
	# Vertical corridor using the path texture rotated 90 degrees
	var top_y := minf(from.y, to.y)
	var bot_y := maxf(from.y, to.y)
	var mid_x := (from.x + to.x) / 2.0
	var length := bot_y - top_y
	var center := Vector2(mid_x, top_y + length / 2.0)

	# Draw the texture rotated 90 degrees around its center
	draw_set_transform(center, PI / 2.0, Vector2.ONE)

	var rect := Rect2(
		Vector2(-length / 2.0, -PATH_THICKNESS / 2.0),
		Vector2(length, PATH_THICKNESS),
	)

	draw_texture_rect(_tex_path, rect, false)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_room(room: RoomData) -> void:
	var pos: Vector2 = _room_positions.get(room.id, Vector2.ZERO)

	if pos == Vector2.ZERO:
		return

	var rect := Rect2(pos - ROOM_SIZE / 2.0, ROOM_SIZE)
	var is_visited: bool = room.id in _visited_rooms
	var is_current: bool = room.id == _current_room_id
	var is_available: bool = room.id in _available_rooms

	var tex := _get_room_texture(room, is_visited)

	if is_available:
		var glow_rect := rect.grow(3)
		draw_rect(glow_rect, COLOR_AVAILABLE_GLOW, true)
		draw_rect(glow_rect, COLOR_AVAILABLE_BORDER, false, 1.5)

	var modulate := Color.WHITE

	if is_visited:
		modulate = COLOR_VISITED_MOD

	draw_texture_rect(tex, rect, false, modulate)


func _get_room_texture(room: RoomData, is_visited: bool) -> Texture2D:
	if not is_visited and room.visibility == "hidden":
		return _tex_hidden

	if not is_visited and room.visibility == "hinted":
		return _tex_hidden

	match room.room_type:
		"monster":
			return _tex_monster
		"boss":
			return _tex_boss
		"treasure":
			return _tex_treasure
		"rest":
			return _tex_rest
		"curse":
			return _tex_curse

	return _tex_hidden


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var click_pos: Vector2 = event.position

		for room_id: String in _available_rooms:
			var rect: Rect2 = _room_rects.get(room_id, Rect2())

			if rect.has_point(click_pos):
				var room := _find_room(room_id)

				if room != null:
					room_clicked.emit(room)
					accept_event()
					return


func _find_room(room_id: String) -> RoomData:
	if _dungeon == null:
		return null

	for seg: DungeonSegmentData in _dungeon.segments:
		if seg.segment_type == "single" and seg.room.id == room_id:
			return seg.room

		if seg.segment_type == "branch":
			for room: RoomData in seg.path_a:
				if room.id == room_id:
					return room

			for room: RoomData in seg.path_b:
				if room.id == room_id:
					return room

	return null
