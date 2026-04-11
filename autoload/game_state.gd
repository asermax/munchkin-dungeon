class_name GameStateClass
extends Node

## References set by BattleManager when battle starts
var turn_queue: RefCounted
var battle_manager: Node

## Dungeon state
var current_dungeon: Resource
var dungeon_manager: Node
