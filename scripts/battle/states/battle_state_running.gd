class_name BattleStateRunning
extends BattleState

## Main battle loop state.
## Drives the timer-paced turn execution each frame.

var _step_timer: float = 0.0
var _action_delay: float = 0.8


func enter() -> void:
	_step_timer = 0.0
	_start_new_round()


func update(delta: float) -> void:
	_step_timer += delta * battle.battle_speed

	if _step_timer >= _action_delay:
		_step_timer = 0.0
		_step()


func _step() -> void:
	var unit = battle.turn_queue.get_next_unit()

	if unit == null:
		_end_round()
		return

	_execute_turn(unit)


func _execute_turn(unit: BattleUnit) -> void:
	# Process DoT effects at start of turn
	var dot_results := unit.tick_effects()
	_emit_dot_results(dot_results, unit)

	if not unit.is_alive:
		battle.handle_death(unit)
		_check_battle_end()
		return

	if unit.is_stunned():
		_emit_stunned(unit)
		return

	# AI picks action
	var sides: Dictionary = battle.get_sides(unit)
	var action: BattleAction = battle.ability_ai.choose_action(unit, sides.allies, sides.enemies, sides.dead_allies)

	if not action.is_valid():
		return

	# Determine the pool of units that targets were drawn from
	var source_pool: Array = []

	match action.ability.target_type:
		"enemy", "all_enemies":
			source_pool = sides.enemies
		"ally", "all_allies":
			source_pool = sides.allies

	# Execute action and emit results
	var results: Array[Dictionary] = action.execute(battle.ability_resolver, source_pool)
	_emit_action_results(results)

	_check_battle_end()


func _start_new_round() -> void:
	battle.turn_queue.start_round()

	# Tick cooldowns at round start (after the first round)
	if battle.turn_queue.get_round_number() > 1:
		for unit: BattleUnit in battle.hero_units:
			if unit.is_alive:
				unit.tick_cooldowns()

		for unit: BattleUnit in battle.enemy_units:
			if unit.is_alive:
				unit.tick_cooldowns()

	battle.round_started.emit(battle.turn_queue.get_round_number())


func _end_round() -> void:
	if not _check_battle_end():
		_start_new_round()


func _check_battle_end() -> bool:
	var heroes_alive: bool = battle.hero_units.any(func(u: BattleUnit) -> bool: return u.is_alive)
	var enemies_alive: bool = battle.enemy_units.any(func(u: BattleUnit) -> bool: return u.is_alive)

	if not enemies_alive:
		battle.end_battle("victory")
		return true

	if not heroes_alive:
		battle.end_battle("defeat")
		return true

	return false


# -- Event emission (inlined from BattleResultEmitter) --

func _emit_dot_results(dot_results: Array[Dictionary], unit: BattleUnit) -> void:
	for dot: Dictionary in dot_results:
		battle.action_resolved.emit({
			"type": "dot",
			"target": unit.get_display_info(),
			"effect": dot.effect,
			"amount": dot.damage,
		})


func _emit_stunned(unit: BattleUnit) -> void:
	battle.action_resolved.emit({
		"type": "stunned",
		"actor": unit.get_display_info(),
	})


func _emit_action_results(results: Array[Dictionary]) -> void:
	for result: Dictionary in results:
		var target_id: String = result.get("target", {}).get("unit_id", "")
		var target_unit = battle.find_unit(target_id)

		var fresh_target: Dictionary = target_unit.get_display_info() if target_unit != null else result.get("target", {})
		result["target"] = fresh_target

		battle.action_resolved.emit(result)

		match result.get("type", ""):
			"damage":
				if not result.get("dodged", false):
					battle.unit_damaged.emit(fresh_target, result.get("amount", 0), result.get("crit", false))

					if result.get("killed", false):
						if target_unit != null:
							battle.handle_death(target_unit)

					elif target_unit != null and target_unit.is_alive and target_unit.check_phase2():
						battle.boss_phase_changed.emit(target_unit.get_display_info(), 2)

			"heal":
				battle.unit_healed.emit(fresh_target, result.get("amount", 0))

			"resurrect":
				if target_unit != null:
					battle.handle_resurrect(target_unit)

				battle.unit_healed.emit(fresh_target, result.get("amount", 0))
