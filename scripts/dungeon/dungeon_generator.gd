class_name DungeonGenerator
extends RefCounted

## Generates a randomized dungeon with branching paths.
## Usage:
##   var dungeon: DungeonData = DungeonGenerator.generate("cave", "medium", 8)

const ROOM_WEIGHTS := {
	"monster": 60,
	"curse": 18,
	"treasure": 10,
	"rest": 12,
}

const MAX_ATTEMPTS := 3


static func generate(biome: String, difficulty: String, target_rooms: int) -> DungeonData:
	target_rooms = clampi(target_rooms, 5, 10)

	for attempt: int in MAX_ATTEMPTS:
		var dungeon := _try_generate(biome, difficulty, target_rooms)

		if _validate(dungeon):
			return dungeon

		push_warning("DungeonGenerator: attempt %d failed validation, retrying" % (attempt + 1))

	# Last resort: force a valid dungeon
	var dungeon := _try_generate(biome, difficulty, target_rooms)
	_force_valid(dungeon)
	return dungeon


static func _try_generate(biome: String, difficulty: String, target_rooms: int) -> DungeonData:
	var dungeon := DungeonData.new()
	dungeon.biome = biome
	dungeon.difficulty = difficulty
	dungeon.max_traversal = target_rooms

	# Step 1: build segment skeleton
	var segments := _build_skeleton(target_rooms)

	# Step 2: assign room types
	_assign_room_types(segments, target_rooms)

	# Step 3: assign encounters
	var pool := EncounterPool.new()
	pool.load_biome(biome)
	_assign_encounters(segments, pool)

	# Step 4: set visibility
	_assign_visibility(segments)

	# Step 5: assign position indices
	_assign_positions(segments)

	dungeon.segments = segments
	dungeon.id = "dungeon_%s_%s_%d" % [biome, difficulty, randi()]
	return dungeon


# -- Step 1: Skeleton --

static func _build_skeleton(target_rooms: int) -> Array[DungeonSegmentData]:
	var segments: Array[DungeonSegmentData] = []

	# First segment: single monster room
	segments.append(_single_segment("monster"))

	# Last segment: single boss room
	var boss_segment := _single_segment("boss")

	# Budget for middle segments (excluding first and last)
	var budget: int = target_rooms - 2

	# Always place at least 1 branch
	var branch_count := 1
	if target_rooms >= 8 and budget >= 5:
		branch_count = 2

	var middle: Array[DungeonSegmentData] = []

	for i: int in branch_count:
		var branch := _build_branch(budget)
		var branch_cost: int = maxi(branch.path_a.size(), branch.path_b.size())
		budget -= branch_cost
		middle.append(branch)

		if budget <= 0:
			break

	# Fill remaining budget with single segments
	for i: int in budget:
		middle.append(_single_segment(""))  # type assigned later

	# Shuffle middle segments so branches aren't always first
	middle.shuffle()

	# Assemble: first + middle + boss
	segments.append_array(middle)
	segments.append(boss_segment)

	return segments


static func _build_branch(budget: int) -> DungeonSegmentData:
	var segment := DungeonSegmentData.new()
	segment.segment_type = "branch"

	# Each path gets 1-2 rooms, constrained by budget
	var max_per_path := mini(2, budget - 1)  # leave at least 1 for the other path
	max_per_path = maxi(max_per_path, 1)

	var path_a_len := randi_range(1, max_per_path)
	var path_b_len := randi_range(1, max_per_path)

	# Make sure total doesn't exceed budget
	var total_cost := maxi(path_a_len, path_b_len)
	if total_cost > budget:
		path_a_len = 1
		path_b_len = 1

	for i: int in path_a_len:
		segment.path_a.append(RoomData.new())

	for i: int in path_b_len:
		segment.path_b.append(RoomData.new())

	return segment


static func _single_segment(room_type: String) -> DungeonSegmentData:
	var segment := DungeonSegmentData.new()
	segment.segment_type = "single"
	segment.room = RoomData.new()
	segment.room.room_type = room_type
	return segment


# -- Step 2: Room type assignment --

static func _assign_room_types(segments: Array[DungeonSegmentData], target_rooms: int) -> void:
	# Collect all rooms that need types assigned (excluding first/last which are preset)
	var rooms_to_assign: Array[RoomData] = []

	for i: int in range(1, segments.size() - 1):
		var seg := segments[i]

		if seg.segment_type == "single" and seg.room.room_type == "":
			rooms_to_assign.append(seg.room)
		elif seg.segment_type == "branch":
			for room: RoomData in seg.path_a:
				rooms_to_assign.append(room)
			for room: RoomData in seg.path_b:
				rooms_to_assign.append(room)

	# Mandatory: midpoint rest for 6+ room dungeons
	var has_rest := false

	if target_rooms >= 6 and not rooms_to_assign.is_empty():
		var mid_index := rooms_to_assign.size() / 2
		rooms_to_assign[mid_index].room_type = "rest"
		has_rest = true

	# Fill unassigned rooms with weighted random types
	var has_treasure := false

	for idx: int in rooms_to_assign.size():
		var room := rooms_to_assign[idx]

		if room.room_type != "":
			continue

		var room_type := _weighted_pick()

		# No consecutive curses: check previous room in this list
		if room_type == "curse" and idx > 0 and rooms_to_assign[idx - 1].room_type == "curse":
			room_type = _weighted_pick_excluding("curse")

		room.room_type = room_type

		if room_type == "treasure":
			has_treasure = true
		if room_type == "rest":
			has_rest = true

	# Guarantee treasure in first 4 positions for 5+ room dungeons
	if target_rooms >= 5 and not has_treasure and not rooms_to_assign.is_empty():
		var force_idx := mini(2, rooms_to_assign.size() - 1)
		rooms_to_assign[force_idx].room_type = "treasure"

	# Guarantee at least 1 rest for 6+ rooms if somehow missed
	if target_rooms >= 6 and not has_rest and not rooms_to_assign.is_empty():
		for room: RoomData in rooms_to_assign:
			if room.room_type == "monster":
				room.room_type = "rest"
				break

	# Final consecutive curse fix across all possible traversal paths
	_fix_consecutive_curses(segments)


static func _weighted_pick() -> String:
	var total := 0

	for weight: int in ROOM_WEIGHTS.values():
		total += weight

	var roll := randi_range(0, total - 1)
	var cumulative := 0

	for room_type: String in ROOM_WEIGHTS:
		cumulative += ROOM_WEIGHTS[room_type]
		if roll < cumulative:
			return room_type

	return "monster"


static func _weighted_pick_excluding(excluded: String) -> String:
	var filtered := {}

	for room_type: String in ROOM_WEIGHTS:
		if room_type != excluded:
			filtered[room_type] = ROOM_WEIGHTS[room_type]

	var total := 0

	for weight: int in filtered.values():
		total += weight

	var roll := randi_range(0, total - 1)
	var cumulative := 0

	for room_type: String in filtered:
		cumulative += filtered[room_type]
		if roll < cumulative:
			return room_type

	return "monster"


static func _fix_consecutive_curses(segments: Array[DungeonSegmentData]) -> void:
	# Check each possible traversal path through the dungeon
	var paths := _get_all_traversal_paths(segments)

	for path: Array in paths:
		for i: int in range(1, path.size()):
			if path[i].room_type == "curse" and path[i - 1].room_type == "curse":
				path[i].room_type = "monster"


static func _get_all_traversal_paths(segments: Array[DungeonSegmentData]) -> Array:
	## Returns all possible room sequences a player could walk through.
	var paths: Array = [[]]

	for seg: DungeonSegmentData in segments:
		if seg.segment_type == "single":
			for path: Array in paths:
				path.append(seg.room)

		elif seg.segment_type == "branch":
			var new_paths: Array = []

			for path: Array in paths:
				# Path A variant
				var path_a := path.duplicate()
				for room: RoomData in seg.path_a:
					path_a.append(room)
				new_paths.append(path_a)

				# Path B variant
				var path_b := path.duplicate()
				for room: RoomData in seg.path_b:
					path_b.append(room)
				new_paths.append(path_b)

			paths = new_paths

	return paths


# -- Step 3: Encounter assignment --

static func _assign_encounters(segments: Array[DungeonSegmentData], pool: EncounterPool) -> void:
	var position := 0

	for seg: DungeonSegmentData in segments:
		if seg.segment_type == "single":
			_assign_room_encounter(seg.room, position, pool)
			position += 1

		elif seg.segment_type == "branch":
			for room: RoomData in seg.path_a:
				_assign_room_encounter(room, position, pool)
				position += 1

			# Reset position for path B (same depth as path A)
			position -= seg.path_a.size()
			for room: RoomData in seg.path_b:
				_assign_room_encounter(room, position, pool)
				position += 1

			# Advance by the max path length
			position -= seg.path_b.size()
			position += maxi(seg.path_a.size(), seg.path_b.size())


static func _assign_room_encounter(room: RoomData, position: int, pool: EncounterPool) -> void:
	if room.room_type == "boss":
		room.encounter = pool.pick_boss()

	elif room.room_type == "monster":
		var difficulty := _position_to_difficulty(position)
		room.encounter = pool.pick(difficulty)


static func _position_to_difficulty(position: int) -> String:
	if position <= 1:
		return "easy" if randf() < 0.7 else "medium"
	elif position <= 3:
		return "medium" if randf() < 0.7 else "hard"
	else:
		return "hard" if randf() < 0.8 else "medium"


# -- Step 4: Visibility --

static func _assign_visibility(segments: Array[DungeonSegmentData]) -> void:
	for seg: DungeonSegmentData in segments:
		if seg.segment_type == "single":
			_set_room_visibility(seg.room)
		elif seg.segment_type == "branch":
			for room: RoomData in seg.path_a:
				_set_room_visibility(room)
			for room: RoomData in seg.path_b:
				_set_room_visibility(room)


static func _set_room_visibility(room: RoomData) -> void:
	match room.room_type:
		"rest":
			room.visibility = "visible"
		"boss":
			room.visibility = "visible"
		"treasure":
			room.visibility = "hinted" if randf() < 0.5 else "hidden"
		_:
			room.visibility = "hidden"


# -- Step 5: Position indices --

static func _assign_positions(segments: Array[DungeonSegmentData]) -> void:
	var position := 0

	for seg: DungeonSegmentData in segments:
		if seg.segment_type == "single":
			seg.room.position_index = position
			seg.room.id = "room_%d" % position
			position += 1

		elif seg.segment_type == "branch":
			var branch_start := position

			for i: int in seg.path_a.size():
				seg.path_a[i].position_index = branch_start + i
				seg.path_a[i].id = "room_%d_a%d" % [branch_start, i]

			for i: int in seg.path_b.size():
				seg.path_b[i].position_index = branch_start + i
				seg.path_b[i].id = "room_%d_b%d" % [branch_start, i]

			position += maxi(seg.path_a.size(), seg.path_b.size())


# -- Validation --

static func _validate(dungeon: DungeonData) -> bool:
	if dungeon.segments.is_empty():
		return false

	# First room must be monster
	var first_seg := dungeon.segments[0]
	if first_seg.segment_type != "single" or first_seg.room.room_type != "monster":
		return false

	# Last room must be boss
	var last_seg := dungeon.segments[dungeon.segments.size() - 1]
	if last_seg.segment_type != "single" or last_seg.room.room_type != "boss":
		return false

	# Check all traversal paths for consecutive curses
	var paths := _get_all_traversal_paths(dungeon.segments)

	for path: Array in paths:
		for i: int in range(1, path.size()):
			if path[i].room_type == "curse" and path[i - 1].room_type == "curse":
				return false

	# Check for at least 1 treasure (5+ rooms) and 1 rest (6+ rooms)
	var all_rooms := _get_all_rooms(dungeon.segments)
	var has_treasure := false
	var has_rest := false

	for room: RoomData in all_rooms:
		if room.room_type == "treasure":
			has_treasure = true
		if room.room_type == "rest":
			has_rest = true

	if dungeon.max_traversal >= 5 and not has_treasure:
		return false

	if dungeon.max_traversal >= 6 and not has_rest:
		return false

	# Must have at least 1 branch
	var has_branch := false

	for seg: DungeonSegmentData in dungeon.segments:
		if seg.segment_type == "branch":
			has_branch = true
			break

	if not has_branch:
		return false

	return true


static func _force_valid(dungeon: DungeonData) -> void:
	## Brute-force fixes for a dungeon that failed validation.
	var all_rooms := _get_all_rooms(dungeon.segments)

	# Fix consecutive curses
	var paths := _get_all_traversal_paths(dungeon.segments)

	for path: Array in paths:
		for i: int in range(1, path.size()):
			if path[i].room_type == "curse" and path[i - 1].room_type == "curse":
				path[i].room_type = "monster"

	# Force treasure if missing
	var has_treasure := false

	for room: RoomData in all_rooms:
		if room.room_type == "treasure":
			has_treasure = true
			break

	if not has_treasure:
		for room: RoomData in all_rooms:
			if room.room_type == "monster" and room != all_rooms[0]:
				room.room_type = "treasure"
				_set_room_visibility(room)
				break

	# Force rest if missing and 6+ rooms
	if dungeon.max_traversal >= 6:
		var has_rest := false

		for room: RoomData in all_rooms:
			if room.room_type == "rest":
				has_rest = true
				break

		if not has_rest:
			for room: RoomData in all_rooms:
				if room.room_type == "monster" and room != all_rooms[0]:
					room.room_type = "rest"
					_set_room_visibility(room)
					break


static func _get_all_rooms(segments: Array[DungeonSegmentData]) -> Array[RoomData]:
	var rooms: Array[RoomData] = []

	for seg: DungeonSegmentData in segments:
		if seg.segment_type == "single":
			rooms.append(seg.room)
		elif seg.segment_type == "branch":
			rooms.append_array(seg.path_a)
			rooms.append_array(seg.path_b)

	return rooms


## Debug: prints dungeon layout to console
static func print_dungeon(dungeon: DungeonData) -> void:
	print("=== Dungeon: %s ===" % dungeon.id)
	print("Biome: %s | Difficulty: %s | Max traversal: %d" % [
		dungeon.biome, dungeon.difficulty, dungeon.max_traversal,
	])

	for i: int in dungeon.segments.size():
		var seg := dungeon.segments[i]

		if seg.segment_type == "single":
			var room := seg.room
			var enc_name := room.encounter.display_name if room.encounter else "—"
			print("  [%d] %s (%s) enc=%s" % [
				room.position_index, room.room_type, room.visibility, enc_name,
			])

		elif seg.segment_type == "branch":
			print("  [BRANCH]")

			for room: RoomData in seg.path_a:
				var enc_name := room.encounter.display_name if room.encounter else "—"
				print("    A: [%d] %s (%s) enc=%s" % [
					room.position_index, room.room_type, room.visibility, enc_name,
				])

			for room: RoomData in seg.path_b:
				var enc_name := room.encounter.display_name if room.encounter else "—"
				print("    B: [%d] %s (%s) enc=%s" % [
					room.position_index, room.room_type, room.visibility, enc_name,
				])

	print("===================")
