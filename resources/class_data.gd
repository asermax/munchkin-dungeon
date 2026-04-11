class_name ClassData
extends Resource

@export var id: String
@export var display_name: String

## Base stats at level 1
@export var base_str: int = 5
@export var base_agi: int = 5
@export var base_vit: int = 5
@export var base_int: int = 5
@export var base_luck: int = 5

## Stat growth per level
@export var str_per_level: float = 0.5
@export var agi_per_level: float = 0.5
@export var vit_per_level: float = 0.5
@export var int_per_level: float = 0.5
@export var luck_per_level: float = 0.5

## Abilities ordered by AI priority (highest first)
@export var abilities: Array[Resource] = []

## Formation preference
@export var preferred_row: String = "front"     # "front" or "back"

## UI
@export var color: Color = Color.WHITE
@export var sprite_path: String = ""
