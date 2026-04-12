class_name DungeonManager
extends Node

## Orchestrates the player's journey through a generated dungeon.
## Tracks position, handles room entry, delegates to battle for combat rooms.

signal room_available(room: RoomData, segment_index: int, path: String, room_index: int)
signal battle_requested(encounter: EncounterData)
signal treasure_found(room: RoomData)
signal curse_triggered(room: RoomData)
signal rest_entered(room: RoomData)

var current_dungeon: DungeonData
var current_segment_index: int = -1
var current_path: String = ""       # "" for single, "a" or "b" for branches
var current_room_index: int = -1    # index within the branch path
var visited_rooms: Dictionary = {}  # room.id -> true

var _is_in_battle: bool = false
var _current_room: RoomData


func start_dungeon(dungeon: DungeonData) -> void:
	current_dungeon = dungeon
	current_segment_index = -1
	current_path = ""
	current_room_index = -1
	visited_rooms.clear()
	_is_in_battle = false
	_current_room = null

	EventBus.dungeon_started.emit(dungeon)

	# Make first room available
	_unlock_next_rooms()


func enter_room(room: RoomData) -> void:
	if _is_in_battle:
		return

	if room.id in visited_rooms:
		return

	_current_room = room

	# Reveal the room type
	room.visibility = "visible"

	# Find where this room is in the dungeon
	_update_position_for_room(room)

	EventBus.room_entered.emit(room)

	match room.room_type:
		"monster", "boss":
			_start_battle(room)
		"treasure":
			treasure_found.emit(room)
		"curse":
			curse_triggered.emit(room)
		"rest":
			rest_entered.emit(room)


func on_battle_ended(_result: Dictionary) -> void:
	_is_in_battle = false

	if _current_room != null:
		_complete_room(_current_room)


func complete_current_room() -> void:
	## Called by the game controller after a modal is dismissed.
	if _current_room != null:
		_complete_room(_current_room)


func get_available_rooms() -> Array[Dictionary]:
	## Returns rooms the player can move to.
	## Each dict has: room, segment_index, path, room_index
	var available: Array[Dictionary] = []

	if current_dungeon == null:
		return available

	# First move: only the first room
	if current_segment_index == -1:
		var first_seg := current_dungeon.segments[0]

		if first_seg.segment_type == "single":
			available.append({
				"room": first_seg.room,
				"segment_index": 0,
				"path": "",
				"room_index": 0,
			})

		return available

	# Within a branch: next room in the same path
	var seg := current_dungeon.segments[current_segment_index]

	if seg.segment_type == "branch" and current_path != "":
		var path_rooms: Array[RoomData] = seg.path_a if current_path == "a" else seg.path_b
		var next_idx := current_room_index + 1

		if next_idx < path_rooms.size():
			var room := path_rooms[next_idx]

			if room.id not in visited_rooms:
				available.append({
					"room": room,
					"segment_index": current_segment_index,
					"path": current_path,
					"room_index": next_idx,
				})

			return available

	# Move to next segment
	var next_seg_idx := current_segment_index + 1

	# If inside a branch, we need to finish the path first
	if seg.segment_type == "branch" and current_path != "":
		var path_rooms: Array[RoomData] = seg.path_a if current_path == "a" else seg.path_b

		if current_room_index < path_rooms.size() - 1:
			return available  # not done with current path yet

	if next_seg_idx >= current_dungeon.segments.size():
		return available  # dungeon complete

	var next_seg := current_dungeon.segments[next_seg_idx]

	if next_seg.segment_type == "single":
		if next_seg.room.id not in visited_rooms:
			available.append({
				"room": next_seg.room,
				"segment_index": next_seg_idx,
				"path": "",
				"room_index": 0,
			})

	elif next_seg.segment_type == "branch":
		# Both path entries become available
		if not next_seg.path_a.is_empty():
			var room := next_seg.path_a[0]

			if room.id not in visited_rooms:
				available.append({
					"room": room,
					"segment_index": next_seg_idx,
					"path": "a",
					"room_index": 0,
				})

		if not next_seg.path_b.is_empty():
			var room := next_seg.path_b[0]

			if room.id not in visited_rooms:
				available.append({
					"room": room,
					"segment_index": next_seg_idx,
					"path": "b",
					"room_index": 0,
				})

	return available


func _start_battle(room: RoomData) -> void:
	_is_in_battle = true
	battle_requested.emit(room.encounter)


func _complete_room(room: RoomData) -> void:
	visited_rooms[room.id] = true
	EventBus.room_completed.emit(room)

	# Check if dungeon is complete (boss defeated)
	if room.room_type == "boss":
		EventBus.dungeon_completed.emit()
		return

	_unlock_next_rooms()


func _unlock_next_rooms() -> void:
	# Trigger UI update by signaling available rooms
	var available := get_available_rooms()

	for entry: Dictionary in available:
		room_available.emit(entry.room, entry.segment_index, entry.path, entry.room_index)


func _update_position_for_room(room: RoomData) -> void:
	for seg_idx: int in current_dungeon.segments.size():
		var seg := current_dungeon.segments[seg_idx]

		if seg.segment_type == "single" and seg.room == room:
			current_segment_index = seg_idx
			current_path = ""
			current_room_index = 0
			return

		if seg.segment_type == "branch":
			for i: int in seg.path_a.size():
				if seg.path_a[i] == room:
					current_segment_index = seg_idx
					current_path = "a"
					current_room_index = i
					return

			for i: int in seg.path_b.size():
				if seg.path_b[i] == room:
					current_segment_index = seg_idx
					current_path = "b"
					current_room_index = i
					return
