class_name UnitData
extends Resource

@export var id: String
@export var display_name: String
@export var race: Resource                      # RaceData
@export var unit_class: Resource                # ClassData
@export var level: int = 1
@export var equipment: Array[Resource] = []     # Array of EquipmentData
