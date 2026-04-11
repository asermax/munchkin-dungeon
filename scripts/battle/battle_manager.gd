class_name BattleManager
extends Node

## Orchestrates the auto-battle loop.
## Paces actions with a timer for visual readability.

var turn_queue: TurnQueue
var ability_ai: AbilityAI
var ability_resolver: AbilityResolver

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


func setup_battle(heroes: Array, encounter: Resource) -> void:
	## heroes: Array of UnitData, encounter: EncounterData
	hero_units.clear()
	enemy_units.clear()
	dead_heroes.clear()
	dead_enemies.clear()
	_battle_result = ""

	# Create hero BattleUnits and assign formation
	var front_count := 0
	var back_count := 0

	for hero_data: Resource in heroes:
		var unit_class: Resource = hero_data.get("unit_class")
		var preferred: String = unit_class.get("preferred_row")

		var assigned_row: String
		var assigned_slot: int

		if preferred == "front" and front_count < 2:
			assigned_row = "front"
			assigned_slot = front_count
			front_count += 1
		elif preferred == "back" and back_count < 2:
			assigned_row = "back"
			assigned_slot = back_count
			back_count += 1
		elif front_count < 2:
			assigned_row = "front"
			assigned_slot = front_count
			front_count += 1
		else:
			assigned_row = "back"
			assigned_slot = back_count
			back_count += 1

		var unit := BattleUnit.from_hero(hero_data, "hero", assigned_row, assigned_slot)
		hero_units.append(unit)

	# Create enemy BattleUnits from encounter
	var e_front := 0
	var e_back := 0

	for i in range(encounter.monsters.size()):
		var monster_data: Resource = encounter.monsters[i]
		var row_pref: String = encounter.formation[i] if i < encounter.formation.size() else "front"

		var m_row: String
		var m_slot: int

		if row_pref == "front" and e_front < 2:
			m_row = "front"
			m_slot = e_front
			e_front += 1
		elif row_pref == "back" and e_back < 2:
			m_row = "back"
			m_slot = e_back
			e_back += 1
		elif e_front < 2:
			m_row = "front"
			m_slot = e_front
			e_front += 1
		else:
			m_row = "back"
			m_slot = e_back
			e_back += 1

		var unit := BattleUnit.from_monster(monster_data, "enemy", m_row, m_slot)

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

	# Register in GameState
	GameState.battle_manager = self
	GameState.turn_queue = turn_queue

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

	for dot: Dictionary in dot_results:
		EventBus.action_resolved.emit({
			"type": "dot",
			"target": unit.get_display_info(),
			"effect": dot.effect,
			"amount": dot.damage,
		})

	# Check if unit died from DoT
	if not unit.is_alive:
		_handle_death(unit)
		EventBus.turn_ended.emit(unit.get_display_info())

		if _check_battle_end():
			return

		return

	# Check if stunned
	if unit.is_stunned():
		EventBus.action_resolved.emit({
			"type": "stunned",
			"actor": unit.get_display_info(),
		})
		EventBus.turn_ended.emit(unit.get_display_info())
		return

	# Determine allies and enemies for AI
	var allies: Array
	var enemies: Array
	var dead_ally_list: Array

	if unit.is_hero:
		allies = hero_units
		enemies = enemy_units
		dead_ally_list = dead_heroes
	else:
		allies = enemy_units
		enemies = hero_units
		dead_ally_list = dead_enemies

	# AI picks action
	var action := ability_ai.choose_action(unit, allies, enemies, dead_ally_list)
	var ability: Resource = action.ability
	var targets: Array = action.targets

	if ability == null or targets.is_empty():
		EventBus.turn_ended.emit(unit.get_display_info())
		return

	# Resolve ability
	var results := ability_resolver.resolve(unit, targets, ability)

	# Emit results — use fresh display info from the actual unit (not the
	# pre-action snapshot stored in result.target)
	for result: Dictionary in results:
		var target_id: String = result.get("target", {}).get("unit_id", "")
		var target_unit: BattleUnit = _find_unit(target_id)

		# Fresh info reflects post-damage/heal state
		var fresh_target: Dictionary = target_unit.get_display_info() if target_unit != null else result.get("target", {})
		result["target"] = fresh_target

		EventBus.action_resolved.emit(result)

		match result.get("type", ""):
			"damage":
				if result.get("dodged", false):
					pass
				else:
					EventBus.unit_damaged.emit(fresh_target, result.get("amount", 0), result.get("crit", false))

					if result.get("killed", false):
						if target_unit != null:
							_handle_death(target_unit)

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
					_handle_resurrect(target_unit)

				EventBus.unit_healed.emit(fresh_target, result.get("amount", 0))

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
		EventBus.battle_ended.emit({"result": "victory"})
		return true

	if not heroes_alive:
		_battle_result = "defeat"
		is_battle_active = false
		EventBus.battle_ended.emit({"result": "defeat"})
		return true

	return false


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
