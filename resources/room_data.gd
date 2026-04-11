class_name RoomData
extends Resource

@export var id: String
@export var room_type: String = "monster"           # "monster", "curse", "treasure", "rest", "boss"

## Encounter for monster/boss rooms (null for other types)
@export var encounter: EncounterData

## Whether the player can see the room type before entering
@export var visibility: String = "hidden"           # "visible", "hinted", "hidden"

## Room's position in the dungeon (0-based, for depth-based scaling)
@export var position_index: int = 0
