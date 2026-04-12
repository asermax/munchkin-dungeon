class_name EventBusClass
extends Node

## Cross-system signals only.
## Battle-internal signals live on BattleManager (consumed by sibling BattleUI).

## Battle lifecycle (cross-system: battle states → Main)
signal battle_ended(result: Dictionary)
signal battle_hero_state_updated(hero_states: Dictionary)

## Dungeon navigation (cross-system: DungeonManager → Main)
signal dungeon_started(dungeon: Resource)
signal room_entered(room: Resource)
signal room_completed(room: Resource)
signal dungeon_completed()
