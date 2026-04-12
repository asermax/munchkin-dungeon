class_name BattleManager
extends Node

## Orchestrates the auto-battle loop.
## Acts as a state machine host: delegates flow to state children.
## Owns battle data and provides helper methods for states.

var turn_queue: TurnQueue
var ability_ai: AbilityAI
var ability_resolver: AbilityResolver

var hero_units: Array = []         # Array of BattleUnit
var enemy_units: Array = []        # Array of BattleUnit
var dead_heroes: Array = []        # For resurrect targeting
var dead_enemies: Array = []

var battle_speed: float = 1.0      # 0=paused, 1=normal, 2=fast, 3=fastest
var battle_result: String = ""     # "victory", "defeat", or ""

var _current_state: Node           # BattleState — untyped to avoid circular dependency
var _states: Dictionary = {}       # StringName -> BattleState

var _basic_attack: Resource


func _ready() -> void:
	set_process(false)

	if turn_queue == null:
		configure()

	_setup_states()


func configure(
	p_turn_queue: TurnQueue = null,
	p_ability_ai: AbilityAI = null,
	p_ability_resolver: AbilityResolver = null,
) -> void:
	turn_queue = p_turn_queue if p_turn_queue != null else TurnQueue.new()
	ability_ai = p_ability_ai if p_ability_ai != null else AbilityAI.new()
	ability_resolver = p_ability_resolver if p_ability_resolver != null else AbilityResolver.new()


func setup_battle(heroes: Array, encounter: Resource, hero_state: Dictionary = {}) -> void:
	hero_units.clear()
	enemy_units.clear()
	dead_heroes.clear()
	dead_enemies.clear()
	battle_result = ""

	# Create hero BattleUnits and assign formation
	var hero_prefs: Array = heroes.map(
		func(h: Resource) -> String: return h.get("unit_class").get("preferred_row"),
	)
	var hero_formations := FormationUtils.assign_formation(hero_prefs)

	for i in range(heroes.size()):
		var f: Dictionary = hero_formations[i]
		var unit := BattleUnit.from_hero(heroes[i], "hero", f.row, f.slot)

		# Apply persisted HP from previous battles
		if hero_state.has(unit.unit_id):
			var state: Dictionary = hero_state[unit.unit_id]
			unit.current_hp = state.current_hp

		hero_units.append(unit)

	# Create enemy BattleUnits from encounter
	var enemy_prefs: Array = []

	for i in range(encounter.monsters.size()):
		enemy_prefs.append(encounter.formation[i] if i < encounter.formation.size() else "front")

	var enemy_formations := FormationUtils.assign_formation(enemy_prefs)

	for i in range(encounter.monsters.size()):
		var f: Dictionary = enemy_formations[i]
		var unit := BattleUnit.from_monster(encounter.monsters[i], "enemy", f.row, f.slot)

		# Make IDs unique when the same monster appears multiple times
		unit.unit_id = "%s_%d" % [unit.unit_id, i]

		enemy_units.append(unit)

	# Load basic attack for AI fallback
	_basic_attack = load("res://data/abilities/basic_attack.tres")
	ability_ai.setup(_basic_attack)

	# Setup turn queue
	var all_units: Array = []
	all_units.append_array(hero_units)
	all_units.append_array(enemy_units)
	turn_queue.setup(all_units)

	# Listen for speed change requests from UI
	if not EventBus.speed_requested.is_connected(set_speed):
		EventBus.speed_requested.connect(set_speed)

	# Signal UI to set up
	EventBus.battle_setup.emit(
		hero_units.map(func(u: BattleUnit) -> Dictionary: return u.get_display_info()),
		enemy_units.map(func(u: BattleUnit) -> Dictionary: return u.get_display_info()),
	)


func start_battle() -> void:
	set_process(true)
	EventBus.battle_started.emit()
	_transition_to(&"running")


func end_battle(result: String) -> void:
	battle_result = result
	set_process(false)
	_transition_to(&"ended")


func set_speed(speed: float) -> void:
	battle_speed = speed

	if _current_state != null and _current_state.name == "Running":
		set_process(speed > 0.0)

	EventBus.speed_changed.emit(speed)


func _process(delta: float) -> void:
	if _current_state != null:
		_current_state.update(delta)


# -- State machine --

func _setup_states() -> void:
	var state_classes := [
		["Idle", BattleStateIdle],
		["Running", BattleStateRunning],
		["Ended", BattleStateEnded],
	]

	for entry: Array in state_classes:
		var state: Node = entry[1].new()
		state.name = entry[0]
		state.battle = self
		add_child(state)
		_states[StringName(entry[0].to_lower())] = state

	_current_state = _states[&"idle"]


func _transition_to(state_name: StringName) -> void:
	var next_state: Node = _states.get(state_name)

	if next_state == null:
		push_error("Unknown battle state: %s" % state_name)
		return

	if _current_state == next_state:
		return

	if _current_state != null:
		_current_state.exit()

	_current_state = next_state
	_current_state.enter()


# -- Data helpers (used by states) --

func get_sides(unit: BattleUnit) -> Dictionary:
	if unit.is_hero:
		return {allies = hero_units, enemies = enemy_units, dead_allies = dead_heroes}

	return {allies = enemy_units, enemies = hero_units, dead_allies = dead_enemies}


func handle_death(unit: BattleUnit) -> void:
	unit.is_alive = false
	EventBus.unit_died.emit(unit.get_display_info())

	if unit.is_hero:
		dead_heroes.append(unit)
	else:
		dead_enemies.append(unit)


func handle_resurrect(unit: BattleUnit) -> void:
	if unit.is_hero:
		dead_heroes.erase(unit)
	else:
		dead_enemies.erase(unit)


func find_unit(unit_id: String) -> BattleUnit:
	for unit: BattleUnit in hero_units:
		if unit.unit_id == unit_id:
			return unit

	for unit: BattleUnit in enemy_units:
		if unit.unit_id == unit_id:
			return unit

	for unit: BattleUnit in dead_heroes:
		if unit.unit_id == unit_id:
			return unit

	for unit: BattleUnit in dead_enemies:
		if unit.unit_id == unit_id:
			return unit

	return null


func emit_hero_state() -> void:
	var states: Dictionary = {}

	for unit: BattleUnit in hero_units:
		states[unit.unit_id] = {
			current_hp = unit.current_hp,
			max_hp = unit.max_hp,
			is_alive = unit.is_alive,
		}

	EventBus.battle_hero_state_updated.emit(states)
