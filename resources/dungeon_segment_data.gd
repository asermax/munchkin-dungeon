class_name DungeonSegmentData
extends Resource

@export var segment_type: String = "single"        # "single" or "branch"

## For "single" segments: one room
@export var room: RoomData

## For "branch" segments: two parallel paths (1-3 rooms each)
@export var path_a: Array[RoomData] = []
@export var path_b: Array[RoomData] = []
