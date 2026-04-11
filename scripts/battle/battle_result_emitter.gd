class_name BattleResultEmitter
extends RefCounted

## Translates ability resolution results into EventBus signals.
## Extracted from BattleManager._execute_turn() to reduce nesting and
## keep BattleManager focused on orchestration.


func emit_dot_results(dot_results: Array[Dictionary], unit: BattleUnit) -> void:
	for dot: Dictionary in dot_results:
		EventBus.action_resolved.emit({
			"type": "dot",
			"target": unit.get_display_info(),
			"effect": dot.effect,
			"amount": dot.damage,
		})


func emit_stunned(unit: BattleUnit) -> void:
	EventBus.action_resolved.emit({
		"type": "stunned",
		"actor": unit.get_display_info(),
	})


func emit_action_results(
	results: Array[Dictionary],
	find_unit_fn: Callable,
	handle_death_fn: Callable,
	handle_resurrect_fn: Callable,
) -> void:
	## Emits EventBus signals for each resolution result.
	## Uses fresh display info from the actual unit (not the pre-action snapshot).
	for result: Dictionary in results:
		var target_id: String = result.get("target", {}).get("unit_id", "")
		var target_unit: BattleUnit = find_unit_fn.call(target_id)

		var fresh_target: Dictionary = target_unit.get_display_info() if target_unit != null else result.get("target", {})
		result["target"] = fresh_target

		EventBus.action_resolved.emit(result)

		match result.get("type", ""):
			"damage":
				if not result.get("dodged", false):
					EventBus.unit_damaged.emit(fresh_target, result.get("amount", 0), result.get("crit", false))

					if result.get("killed", false):
						if target_unit != null:
							handle_death_fn.call(target_unit)

					elif target_unit != null and target_unit.is_alive and target_unit.check_phase2():
						EventBus.boss_phase_changed.emit(target_unit.get_display_info(), 2)

			"heal":
				EventBus.unit_healed.emit(fresh_target, result.get("amount", 0))

			"buff", "debuff", "taunt":
				var buff_name: String = result.get("effect", result.get("ability_name", ""))
				var duration: int = result.get("duration", 0)
				EventBus.buff_applied.emit(fresh_target, buff_name, duration)

			"resurrect":
				if target_unit != null:
					handle_resurrect_fn.call(target_unit)

				EventBus.unit_healed.emit(fresh_target, result.get("amount", 0))
