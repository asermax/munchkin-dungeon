class_name RoomHandler
extends Node

## Handles room outcome modals for treasure, curse, rest, and battle loot.
## Each handler creates a RoomResultModal, shows it, and connects dismissal
## to dungeon progression.

var _dungeon_manager: DungeonManager
var _hero_state_manager: HeroStateManager
var _rebuild_party_callback: Callable


func setup(
	dungeon_manager: DungeonManager,
	hero_state_manager: HeroStateManager,
	rebuild_party_callback: Callable,
) -> void:
	_dungeon_manager = dungeon_manager
	_hero_state_manager = hero_state_manager
	_rebuild_party_callback = rebuild_party_callback


func handle_battle_ended(result: Dictionary) -> void:
	var battle_result: String = result.get("result", "defeat")
	var gold := 0
	var items: Array[String] = []

	if battle_result == "victory":
		gold = randi_range(10, 30)

		if randf() < 0.4:
			items.append(_random_loot_name())

	var modal := RoomResultModal.new()
	add_child(modal)
	modal.show_battle_loot(battle_result, gold, items)
	modal.dismissed.connect(func() -> void:
		_dungeon_manager.on_battle_ended(result)
	)


func handle_treasure(room: RoomData) -> void:
	var gold := randi_range(15, 40)
	var items: Array[String] = []

	if randf() < 0.7:
		items.append(_random_loot_name())

	if randf() < 0.2:
		items.append(_random_loot_name())

	var modal := RoomResultModal.new()
	add_child(modal)
	modal.show_treasure(gold, items)
	modal.dismissed.connect(func() -> void:
		_dungeon_manager.complete_current_room()
	)


func handle_curse(room: RoomData) -> void:
	var curses := [
		["Wet Socks", "Everyone's boots are soaked. -1 initiative until next rest."],
		["Butter Fingers", "Someone greased the weapon handles. -1 damage until next rest."],
		["Ominous Fog", "A thick fog rolls in. -5% dodge chance until next rest."],
		["Bad Omen", "A black cat crossed the path. -2 luck until next rest."],
		["Spooky Whispers", "The walls won't shut up. -1 to all stats until next rest."],
		["Haunted Gear", "Your hat crumbles to dust. A piece of equipment is lost!"],
		["Gravity Hiccup", "Everything feels heavier. -2 defense until next rest."],
		["Echo of Dread", "Morale drops. The next battle feels harder."],
	]

	var curse: Array = curses.pick_random()

	var modal := RoomResultModal.new()
	add_child(modal)
	modal.show_curse(curse[0], curse[1])
	modal.dismissed.connect(func() -> void:
		_dungeon_manager.complete_current_room()
	)


func handle_rest(room: RoomData) -> void:
	var heal_amount := randi_range(20, 40)

	_hero_state_manager.apply_heal(heal_amount)
	_rebuild_party_callback.call()

	var modal := RoomResultModal.new()
	add_child(modal)
	modal.show_rest(heal_amount)
	modal.dismissed.connect(func() -> void:
		_dungeon_manager.complete_current_room()
	)


func _random_loot_name() -> String:
	var loot_names := [
		"Rusty Shortsword (+2 DMG)",
		"Leather Cap (+1 DEF)",
		"Worn Boots (+2 INIT)",
		"Iron Buckler (+3 DEF)",
		"Chipped Staff (+2 Magic DMG)",
		"Lucky Charm (+1 LUCK)",
		"Tattered Cloak (+1 AGI)",
		"Potion of Minor Healing",
		"Dented Helmet (+2 DEF)",
		"Crude Mace (+3 DMG)",
		"Hobbit's Sling (+1 AGI, +1 DMG)",
		"Moldy Cheese (restores 15 HP)",
		"Cursed Ring (looks shiny...)",
		"The Bucket (+4 DEF, -2 dignity)",
	]

	return loot_names.pick_random()
