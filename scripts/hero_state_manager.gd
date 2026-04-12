class_name HeroStateManager
extends RefCounted

## Manages hero data and persisted state across battles.
## Provides a clean API for querying and mutating hero HP/alive state.

var _heroes: Array = []

## hero_id -> {current_hp, max_hp, is_alive}
var _state: Dictionary = {}


func load_heroes(hero_paths: Array[String]) -> void:
	_heroes.clear()

	for path: String in hero_paths:
		_heroes.append(load(path))

	reset()


func reset() -> void:
	_state.clear()

	for hero_data: Resource in _heroes:
		var stats := StatCalculator.compute_hero_stats(hero_data)
		_state[hero_data.id] = {
			current_hp = stats.max_hp,
			max_hp = stats.max_hp,
			is_alive = true,
		}


func get_heroes() -> Array:
	return _heroes


func get_alive_heroes() -> Array:
	var alive: Array = []

	for hero_data: Resource in _heroes:
		if _state.get(hero_data.id, {}).get("is_alive", true):
			alive.append(hero_data)

	return alive


func get_state() -> Dictionary:
	return _state


func apply_heal(heal_amount: int) -> void:
	for hero_id: String in _state:
		var state: Dictionary = _state[hero_id]

		if state.is_alive:
			state.current_hp = mini(state.max_hp, state.current_hp + heal_amount)


func update_from_battle(states: Dictionary) -> void:
	for hero_id: String in states:
		_state[hero_id] = states[hero_id]
