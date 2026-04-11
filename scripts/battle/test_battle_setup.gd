extends Node

## Test harness that starts a battle on _ready.
## Loads test heroes and an encounter, then kicks off the auto-battle.


func _ready() -> void:
	# Wait a frame so the scene tree is fully set up
	await get_tree().process_frame

	var heroes: Array = [
		load("res://data/heroes/test_warrior.tres"),
		load("res://data/heroes/test_rogue.tres"),
		load("res://data/heroes/test_mage.tres"),
		load("res://data/heroes/test_cleric.tres"),
	]

	var encounter: Resource = load("res://data/encounters/cave/hard_1.tres")

	# Find BattleManager in the scene tree
	var battle_manager: BattleManager = get_node_or_null("/root/Main/BattleManager")

	if battle_manager == null:
		push_error("BattleManager not found in scene tree!")
		return

	battle_manager.setup_battle(heroes, encounter)
	battle_manager.start_battle()
