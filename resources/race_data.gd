class_name RaceData
extends Resource

@export var id: String
@export var display_name: String

## Stat modifiers (additive on top of class base stats)
@export var str_mod: int = 0
@export var agi_mod: int = 0
@export var vit_mod: int = 0
@export var int_mod: int = 0
@export var luck_mod: int = 0

## Class restrictions — list of class ids this race cannot be
@export var restricted_classes: Array[String] = []

## Racial trait
@export var trait_id: String = ""               # "adaptive", "thick_skull", "foresight", "sturdy"
@export var trait_description: String = ""
