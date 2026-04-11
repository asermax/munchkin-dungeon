class_name DungeonData
extends Resource

@export var id: String
@export var biome: String = "cave"
@export var difficulty: String = "medium"           # "easy", "medium", "hard"

## Ordered list of segments (single rooms or branches)
@export var segments: Array[DungeonSegmentData] = []

## Rooms in the longest possible traversal path
@export var max_traversal: int = 0
