class_name BattleManager
extends Node

## Orchestrates the auto-battle loop.
## Paces actions with a timer for visual readability.

var turn_queue: TurnQueue
var ability_ai: AbilityAI
var ability_resolver: AbilityResolver
var _result_emitter: BattleResultEmitter

var hero_units: Array = []         # Array of BattleUnit
var enemy_units: Array = []        # Array of BattleUnit
var dead_heroes: Array = []        # For resurrect targeting
var dead_enemies: Array = []

var is_battle_active: bool = false
var battle_speed: float = 1.0      # 0=paused, 1=normal, 2=fast, 3=fastest
var _step_timer: float = 0.0
var _action_delay: float = 0.8     # seconds between actions at speed 1.0
var _round_started: bool = false
var _battle_result: String = ""    # "victory", "defeat", or ""

var _basic_attack: Resource


func _ready() -> void:
	turn_queue = TurnQueue.new()
	ability_ai = AbilityAI.new()
	ability_resolver = AbilityResolver.new()
	_result_emitter = BattleResultEmitter.new()


func setup_battle(heroes: Array, encounter: Resource, hero_state: Dictionary = {}) -> void:
	## heroes: Array of UnitData, encounter: EncounterData, hero_state: persisted HP/alive state
	hero_units.clear()
	enemy_units.clear()
	dead_heroes.clear()
	dead_enemies.clear()
	_battle_result = ""

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
	is_battle_active = true
	_round_started = false
	EventBus.battle_started.emit()

	# Start the first round
	_start_new_round()


func set_speed(speed: float) -> void:
	battle_speed = speed
	EventBus.speed_changed.emit(speed)


func _process(delta: float) -> void:
	if not is_battle_active or battle_speed == 0.0:
		return

	_step_timer += delta * battle_speed

	if _step_timer >= _action_delay:
		_step_timer = 0.0
		_step()


func _step() -> void:
	var unit: BattleUnit = turn_queue.get_next_unit()

	if unit == null:
		_end_round()
		return

	_execute_turn(unit)


func _execute_turn(unit: BattleUnit) -> void:
	EventBus.turn_started.emit(unit.get_display_info())

	# Process DoT effects at start of turn
	var dot_results := unit.tick_effects()
	_result_emitter.emit_dot_results(dot_results, unit)

	if not unit.is_alive:
		_handle_death(unit)
		EventBus.turn_ended.emit(unit.get_display_info())
		_check_battle_end()
		return

	if unit.is_stunned():
		_result_emitter.emit_stunned(unit)
		EventBus.turn_ended.emit(unit.get_display_info())
		return

	# AI picks action
	var sides := _get_sides(unit)
	var action := ability_ai.choose_action(unit, sides.allies, sides.enemies, sides.dead_allies)

	if action.ability == null or action.targets.is_empty():
		EventBus.turn_ended.emit(unit.get_display_info())
		return

	# Determine the pool of units that targets were drawn from
	var source_pool: Array = []

	match action.ability.target_type:
		"enemy", "all_enemies":
			source_pool = sides.enemies
		"ally", "all_allies":
			source_pool = sides.allies

	# Resolve ability and emit results
	var results := ability_resolver.resolve(unit, action.targets, action.ability, source_pool)
	_result_emitter.emit_action_results(results, _find_unit, _handle_death, _handle_resurrect)

	EventBus.turn_ended.emit(unit.get_display_info())
	_check_battle_end()


func _start_new_round() -> void:
	turn_queue.start_round()
	_round_started = true

	# Tick cooldowns at round start (after the first round)
	if turn_queue.get_round_number() > 1:
		for unit: BattleUnit in hero_units:
			if unit.is_alive:
				unit.tick_cooldowns()

		for unit: BattleUnit in enemy_units:
			if unit.is_alive:
				unit.tick_cooldowns()

	EventBus.round_started.emit(turn_queue.get_round_number())


func _end_round() -> void:
	EventBus.round_ended.emit(turn_queue.get_round_number())

	if not _check_battle_end():
		_start_new_round()


func _check_battle_end() -> bool:
	var heroes_alive := hero_units.any(func(u: BattleUnit) -> bool: return u.is_alive)
	var enemies_alive := enemy_units.any(func(u: BattleUnit) -> bool: return u.is_alive)

	if not enemies_alive:
		_battle_result = "victory"
		is_battle_active = false
		_emit_hero_state()
		EventBus.battle_ended.emit({"result": "victory"})
		return true

	if not heroes_alive:
		_battle_result = "defeat"
		is_battle_active = false
		_emit_hero_state()
		EventBus.battle_ended.emit({"result": "defeat"})
		return true

	return false


func _emit_hero_state() -> void:
	var states: Dictionary = {}

	for unit: BattleUnit in hero_units:
		states[unit.unit_id] = {
			current_hp = unit.current_hp,
			max_hp = unit.max_hp,
			is_alive = unit.is_alive,
		}

	EventBus.battle_hero_state_updated.emit(states)


func _get_sides(unit: BattleUnit) -> Dictionary:
	## Returns {allies, enemies, dead_allies} arrays relative to the given unit.
	if unit.is_hero:
		return {allies = hero_units, enemies = enemy_units, dead_allies = dead_heroes}

	return {allies = enemy_units, enemies = hero_units, dead_allies = dead_enemies}


func _handle_death(unit: BattleUnit) -> void:
	unit.is_alive = false
	EventBus.unit_died.emit(unit.get_display_info())

	if unit.is_hero:
		dead_heroes.append(unit)
	else:
		dead_enemies.append(unit)


func _handle_resurrect(unit: BattleUnit) -> void:
	if unit.is_hero:
		dead_heroes.erase(unit)
	else:
		dead_enemies.erase(unit)


func _find_unit(unit_id: String) -> BattleUnit:
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
