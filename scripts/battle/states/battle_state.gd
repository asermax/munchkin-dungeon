class_name BattleState
extends Node

## Base class for battle states.
## Each state receives a reference to the owning BattleManager.

signal state_finished(next_state_name: StringName)

## Reference to the owning BattleManager. Typed as Node to avoid circular dependency.
var battle: Node


func enter() -> void:
	pass


func exit() -> void:
	pass


func update(_delta: float) -> void:
	pass
