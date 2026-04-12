class_name BattleStateEnded
extends BattleState

## Terminal state after battle concludes.
## Emits hero state and battle result, then waits for scene cleanup.


func enter() -> void:
	battle.emit_hero_state()
	EventBus.battle_ended.emit({"result": battle.battle_result})
