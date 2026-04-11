extends Control

## Game root controller.
## Generates a dungeon, wires up navigation and battle, and manages scene transitions.

const BATTLE_SCENE := preload("res://scenes/battle/battle.tscn")

@onready var _content_area: Control = $ContentArea
@onready var _dungeon_map: DungeonMapUI = $MapBar/DungeonMap
@onready var _dungeon_manager: DungeonManager = $DungeonManager

var _battle_instance: Node
var _battle_manager: BattleManager
var _party_view: PartyView

## Test heroes used until party management is implemented
var _heroes: Array = []

## Persisted hero state across battles: hero_id -> {current_hp, max_hp, is_alive}
var _hero_state: Dictionary = {}


func _ready() -> void:
	_load_test_heroes()
	_init_hero_state()
	_build_party_view()
	_connect_signals()
	_start_new_dungeon()


func _load_test_heroes() -> void:
	_heroes = [
		load("res://data/heroes/test_warrior.tres"),
		load("res://data/heroes/test_rogue.tres"),
		load("res://data/heroes/test_mage.tres"),
		load("res://data/heroes/test_cleric.tres"),
	]


func _init_hero_state() -> void:
	_hero_state.clear()

	for hero_data: Resource in _heroes:
		var stats := StatCalculator.compute_hero_stats(hero_data)
		_hero_state[hero_data.id] = {
			current_hp = stats.max_hp,
			max_hp = stats.max_hp,
			is_alive = true,
		}


func _build_party_view() -> void:
	_party_view = PartyView.new()
	_party_view.name = "PartyView"
	_party_view.set_anchors_preset(Control.PRESET_FULL_RECT)
	_content_area.add_child(_party_view)
	_party_view.setup(_heroes, _hero_state)


func _connect_signals() -> void:
	_dungeon_map.room_clicked.connect(_on_room_clicked)
	_dungeon_manager.battle_requested.connect(_on_battle_requested)
	_dungeon_manager.treasure_found.connect(_on_treasure_found)
	_dungeon_manager.curse_triggered.connect(_on_curse_triggered)
	_dungeon_manager.rest_entered.connect(_on_rest_entered)

	EventBus.battle_ended.connect(_on_battle_ended)
	EventBus.room_entered.connect(_on_room_entered)
	EventBus.room_completed.connect(_on_room_completed)
	EventBus.dungeon_completed.connect(_on_dungeon_completed)
	EventBus.dungeon_started.connect(_on_dungeon_started)


func _start_new_dungeon() -> void:
	_init_hero_state()
	_rebuild_party_view()

	var target_rooms := randi_range(7, 10)
	var dungeon := DungeonGenerator.generate("cave", "hard", target_rooms)

	DungeonGenerator.print_dungeon(dungeon)

	_dungeon_map.setup(dungeon)
	_dungeon_manager.start_dungeon(dungeon)


# -- Signal handlers --

func _on_dungeon_started(_dungeon: DungeonData) -> void:
	_update_available_rooms()


func _on_room_clicked(room: RoomData) -> void:
	_dungeon_manager.enter_room(room)


func _on_room_entered(room: RoomData) -> void:
	_dungeon_map.set_current_room(room.id)
	_dungeon_map.reveal_room(room.id)


func _on_room_completed(room: RoomData) -> void:
	_dungeon_map.mark_room_visited(room.id)
	_update_available_rooms()


func _on_dungeon_completed() -> void:
	print("Dungeon complete!")
	# Future: show results, return to base
	# For now, generate a new dungeon after a short delay
	await get_tree().create_timer(2.0).timeout
	_start_new_dungeon()


func _on_battle_requested(encounter: EncounterData) -> void:
	_spawn_battle(encounter)


func _on_battle_ended(result: Dictionary) -> void:
	# Save hero state from battle before despawning
	_save_hero_state()

	# Wait for the result overlay to show briefly
	await get_tree().create_timer(1.5).timeout
	_despawn_battle()

	# Rebuild party view with updated state
	_rebuild_party_view()

	# Show loot modal
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


func _on_treasure_found(_room: RoomData) -> void:
	var gold := randi_range(15, 40)
	var items: Array[String] = []

	# 70% chance of finding equipment
	if randf() < 0.7:
		items.append(_random_loot_name())

	# Small chance of a second item
	if randf() < 0.2:
		items.append(_random_loot_name())

	var modal := RoomResultModal.new()
	add_child(modal)
	modal.show_treasure(gold, items)
	modal.dismissed.connect(func() -> void:
		_dungeon_manager.complete_current_room()
	)


func _on_curse_triggered(_room: RoomData) -> void:
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


func _on_rest_entered(_room: RoomData) -> void:
	var heal_amount := randi_range(20, 40)

	# Heal surviving heroes
	for hero_id: String in _hero_state:
		var state: Dictionary = _hero_state[hero_id]
		if state.is_alive:
			state.current_hp = mini(state.max_hp, state.current_hp + heal_amount)

	_rebuild_party_view()

	var modal := RoomResultModal.new()
	add_child(modal)
	modal.show_rest(heal_amount)
	modal.dismissed.connect(func() -> void:
		_dungeon_manager.complete_current_room()
	)


# -- Battle scene management --

func _spawn_battle(encounter: EncounterData) -> void:
	if _battle_instance != null:
		return

	# Only include alive heroes in battle
	var alive_heroes := _get_alive_heroes()

	if alive_heroes.is_empty():
		push_warning("No alive heroes to fight!")
		return

	_party_view.visible = false

	_battle_instance = BATTLE_SCENE.instantiate()
	_content_area.add_child(_battle_instance)

	# Find the BattleManager in the battle scene
	_battle_manager = _battle_instance.get_node("BattleManager") as BattleManager

	if _battle_manager == null:
		push_error("BattleManager not found in battle scene")
		return

	# Wait a frame for the scene to be ready
	await get_tree().process_frame

	_battle_manager.setup_battle(alive_heroes, encounter, _hero_state)
	_battle_manager.start_battle()


func _despawn_battle() -> void:
	if _battle_instance != null:
		_battle_instance.queue_free()
		_battle_instance = null
		_battle_manager = null

	_party_view.visible = true


# -- Hero state management --

func _get_alive_heroes() -> Array:
	var alive: Array = []

	for hero_data: Resource in _heroes:
		if _hero_state.get(hero_data.id, {}).get("is_alive", true):
			alive.append(hero_data)

	return alive


func _save_hero_state() -> void:
	if _battle_manager == null:
		return

	for unit: BattleUnit in _battle_manager.hero_units:
		_hero_state[unit.unit_id] = {
			current_hp = unit.current_hp,
			max_hp = unit.max_hp,
			is_alive = unit.is_alive,
		}


func _rebuild_party_view() -> void:
	_party_view.setup(_heroes, _hero_state)


# -- Map state sync --

func _update_available_rooms() -> void:
	var available := _dungeon_manager.get_available_rooms()
	var ids: Array[String] = []

	for entry: Dictionary in available:
		ids.append(entry.room.id)

	_dungeon_map.set_available_rooms(ids)


# -- Loot generation --

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
