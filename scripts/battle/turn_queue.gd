class_name TurnQueue
extends RefCounted

## Round-based initiative sorting.
## Each round, all living units are sorted by initiative and each acts once.

var _units: Array = []          # All BattleUnit references
var _turn_order: Array = []     # Sorted for current round
var _current_index: int = 0
var _round_number: int = 0


func setup(units: Array) -> void:
	_units = units
	_round_number = 0


func start_round() -> void:
	_round_number += 1

	# Rebuild turn order: living units sorted by initiative with random jitter
	_turn_order = _units.filter(func(u: BattleUnit) -> bool: return u.is_alive)

	# Roll jittered initiative for each unit this round
	var jittered: Dictionary = {}

	for unit: BattleUnit in _turn_order:
		jittered[unit] = unit.initiative + randi_range(-4, 4)

	_turn_order.sort_custom(func(a: BattleUnit, b: BattleUnit) -> bool:
		var a_init: int = jittered[a]
		var b_init: int = jittered[b]

		if a_init != b_init:
			return a_init > b_init

		# Random tie-break so neither side is favored
		return randi() % 2 == 0
	)

	_current_index = 0


func get_next_unit() -> BattleUnit:
	## Returns the next living unit, or null if round is over.
	while _current_index < _turn_order.size():
		var unit: BattleUnit = _turn_order[_current_index]
		_current_index += 1

		if unit.is_alive:
			return unit

	return null


func remove_unit(unit: BattleUnit) -> void:
	## Mark unit as dead so it's skipped in remaining turns this round.
	unit.is_alive = false


func is_round_over() -> bool:
	return _current_index >= _turn_order.size()


func get_round_number() -> int:
	return _round_number


func get_living_count(hero_side: bool) -> int:
	var count := 0

	for unit: BattleUnit in _units:
		if unit.is_alive and unit.is_hero == hero_side:
			count += 1

	return count
