class_name EncounterData
extends Resource

@export var id: String
@export var display_name: String

## Difficulty tier for encounter pool categorization
@export var difficulty: String = "easy"            # "easy", "medium", "hard", "boss"

## Monsters in this encounter
@export var monsters: Array[Resource] = []      # Array of MonsterData

## Position per monster, matching indices with monsters array
@export var formation: Array[String] = []       # "front" or "back" per monster
