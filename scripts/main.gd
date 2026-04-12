extends Control

## Game root controller.
## Thin coordinator: wires up subsystems and delegates to focused classes.

const BATTLE_SCENE := preload("res://scenes/battle/battle.tscn")

@onready var _content_area: Control = $ContentArea
@onready var _dungeon_map: DungeonMapUI = $MapBar/DungeonMap
@onready var _dungeon_manager: DungeonManager = $DungeonManager

var _battle_instance: Node
var _battle_manager: BattleManager
var _party_view: PartyView
var _hero_state_manager: HeroStateManager
var _room_handler: RoomHandler


func _ready() -> void:
	_hero_state_manager = HeroStateManager.new()
	_hero_state_manager.load_heroes([
		"res://data/heroes/test_warrior.tres",
		"res://data/heroes/test_rogue.tres",
		"res://data/heroes/test_mage.tres",
		"res://data/heroes/test_cleric.tres",
	])

	_room_handler = RoomHandler.new()
	_room_handler.name = "RoomHandler"
	add_child(_room_handler)
	_room_handler.setup(_dungeon_manager, _hero_state_manager, _rebuild_party_view)

	_build_party_view()
	_connect_signals()
	_start_new_dungeon()


func _build_party_view() -> void:
	_party_view = PartyView.new()
	_party_view.name = "PartyView"
	_party_view.set_anchors_preset(Control.PRESET_FULL_RECT)
	_content_area.add_child(_party_view)
	_party_view.setup(_hero_state_manager.get_heroes(), _hero_state_manager.get_state())


func _connect_signals() -> void:
	_dungeon_map.room_clicked.connect(_on_room_clicked)
	_dungeon_manager.battle_requested.connect(_on_battle_requested)
	_dungeon_manager.treasure_found.connect(_room_handler.handle_treasure)
	_dungeon_manager.curse_triggered.connect(_room_handler.handle_curse)
	_dungeon_manager.rest_entered.connect(_room_handler.handle_rest)

	EventBus.battle_ended.connect(_on_battle_ended)
	EventBus.battle_hero_state_updated.connect(_hero_state_manager.update_from_battle)
	EventBus.room_entered.connect(_on_room_entered)
	EventBus.room_completed.connect(_on_room_completed)
	EventBus.dungeon_completed.connect(_on_dungeon_completed)
	EventBus.dungeon_started.connect(_on_dungeon_started)


func _start_new_dungeon() -> void:
	_hero_state_manager.reset()
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
	await get_tree().create_timer(2.0).timeout
	_start_new_dungeon()


func _on_battle_requested(encounter: EncounterData) -> void:
	_spawn_battle(encounter)


func _on_battle_ended(result: Dictionary) -> void:
	await get_tree().create_timer(1.5).timeout
	_despawn_battle()
	_rebuild_party_view()
	_room_handler.handle_battle_ended(result)


# -- Battle scene management --

func _spawn_battle(encounter: EncounterData) -> void:
	if _battle_instance != null:
		return

	var alive_heroes := _hero_state_manager.get_alive_heroes()

	if alive_heroes.is_empty():
		push_warning("No alive heroes to fight!")
		return

	_party_view.visible = false

	_battle_instance = BATTLE_SCENE.instantiate()
	_content_area.add_child(_battle_instance)

	_battle_manager = _battle_instance.get_node("BattleManager") as BattleManager

	if _battle_manager == null:
		push_error("BattleManager not found in battle scene")
		return

	await get_tree().process_frame

	_battle_manager.setup_battle(alive_heroes, encounter, _hero_state_manager.get_state())
	_battle_manager.start_battle()


func _despawn_battle() -> void:
	if _battle_instance != null:
		_battle_instance.queue_free()
		_battle_instance = null
		_battle_manager = null

	_party_view.visible = true


func _rebuild_party_view() -> void:
	_party_view.setup(_hero_state_manager.get_heroes(), _hero_state_manager.get_state())


# -- Map state sync --

func _update_available_rooms() -> void:
	var available := _dungeon_manager.get_available_rooms()
	var ids: Array[String] = []

	for entry: Dictionary in available:
		ids.append(entry.room.id)

	_dungeon_map.set_available_rooms(ids)
