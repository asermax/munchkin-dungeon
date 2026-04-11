class_name EventBusClass
extends Node

## Battle flow
signal battle_started()
signal battle_ended(result: Dictionary)
signal round_started(round_number: int)
signal round_ended(round_number: int)

## Turn events
signal turn_started(unit_info: Dictionary)
signal turn_ended(unit_info: Dictionary)
signal action_resolved(action_info: Dictionary)

## Unit events
signal unit_damaged(unit_info: Dictionary, amount: int, is_crit: bool)
signal unit_healed(unit_info: Dictionary, amount: int)
signal unit_died(unit_info: Dictionary)
signal buff_applied(unit_info: Dictionary, buff_name: String, duration: int)
signal boss_phase_changed(unit_info: Dictionary, phase: int)

## UI
signal battle_setup(hero_units: Array, monster_units: Array)
signal speed_changed(new_speed: float)

## Dungeon navigation
signal dungeon_started(dungeon: Resource)
signal room_entered(room: Resource)
signal room_completed(room: Resource)
signal dungeon_completed()
signal dungeon_fled()
