class_name AbilityAI
extends RefCounted

## Evaluates priority trees to pick the best action for auto-battle.
## Conditions are declarative (AIConditionData resources).
## Target strategies are a callable registry — extensible via register_strategy().

const MELEE_BACKROW_REACH_CHANCE: float = 0.30
const MELEE_BACKROW_WEIGHT: float = 0.4
const FOCUS_FIRE_WEIGHT: float = 2.0

var _basic_attack: Resource
var _target_strategy_registry: Dictionary = {}


func _init() -> void:
	_register_default_strategies()


func setup(basic_attack: Resource) -> void:
	_basic_attack = basic_attack


func register_strategy(strategy_name: String, strategy: Callable) -> void:
	_target_strategy_registry[strategy_name] = strategy


# -- Action selection --

func choose_action(actor: BattleUnit, allies: Array, enemies: Array, dead_allies: Array) -> BattleAction:
	for ab: Resource in actor.abilities:
		if ab.id == "basic_attack":
			continue

		if not actor.is_ability_ready(ab.id):
			continue

		if not _check_condition(ab.ai_condition, actor, allies, enemies, dead_allies):
			continue

		var targets := _select_targets(actor, ab, allies, enemies, dead_allies)

		if targets.is_empty():
			continue

		return BattleAction.create(actor, ab, targets)

	# Fallback: basic attack
	var basic := _basic_attack if _basic_attack != null else _find_basic_attack(actor)
	var basic_targets := _select_targets(actor, basic, allies, enemies, dead_allies)

	return BattleAction.create(actor, basic, basic_targets)


# -- Declarative condition evaluation --

func _check_condition(condition: Resource, actor: BattleUnit, allies: Array, enemies: Array, dead_allies: Array) -> bool:
	if condition == null or condition.scope == "always":
		return true

	# Individual scopes — check each unit against the condition
	match condition.scope:
		"self":
			return _evaluate_unit(actor, condition)

		"any_ally":
			return allies.any(func(u: BattleUnit) -> bool:
				return u.is_alive and _evaluate_unit(u, condition)
			)

		"any_enemy":
			return enemies.any(func(u: BattleUnit) -> bool:
				return u.is_alive and _evaluate_unit(u, condition)
			)

	# Group scopes — measure a pool-level property
	var pool: Array = _get_pool_for_scope(condition.scope, allies, enemies, dead_allies)
	var measured := _get_group_property(pool, condition.property)

	return _compare(measured, condition.compare, condition.value)


func _evaluate_unit(unit: BattleUnit, condition: Resource) -> bool:
	var measured := _get_unit_property(unit, condition.property)
	return _compare(measured, condition.compare, condition.value)


func _get_unit_property(unit: BattleUnit, property: String) -> float:
	match property:
		"hp_pct":
			return float(unit.current_hp) / float(unit.max_hp)
		"has_negative_effect":
			return 1.0 if unit.has_negative_effect() else 0.0

	push_warning("Unknown unit property: %s" % property)
	return 0.0


func _get_group_property(pool: Array, property: String) -> float:
	match property:
		"alive_count":
			return float(pool.filter(func(u: BattleUnit) -> bool: return u.is_alive).size())
		"count":
			return float(pool.size())

	push_warning("Unknown group property: %s" % property)
	return 0.0


func _get_pool_for_scope(scope: String, allies: Array, enemies: Array, dead_allies: Array) -> Array:
	match scope:
		"allies":
			return allies
		"enemies":
			return enemies
		"dead_allies":
			return dead_allies

	push_warning("Unknown group scope: %s" % scope)
	return []


func _compare(measured: float, compare: String, value: float) -> bool:
	match compare:
		"lt":
			return measured < value
		"lte":
			return measured <= value
		"gt":
			return measured > value
		"gte":
			return measured >= value
		"eq":
			return is_equal_approx(measured, value)

	push_warning("Unknown comparator: %s" % compare)
	return false


# -- Target selection --

func _select_targets(actor: BattleUnit, ability: Resource, allies: Array, enemies: Array, dead_allies: Array) -> Array:
	match ability.target_type:
		"self":
			return [actor]

		"all_enemies":
			if ability.reach == "melee":
				return _get_melee_targets(enemies)
			return enemies.filter(func(u: BattleUnit) -> bool: return u.is_alive)

		"all_allies":
			return allies.filter(func(u: BattleUnit) -> bool: return u.is_alive)

		"enemy":
			return _pick_enemy_target(actor, ability, enemies)

		"ally":
			return _pick_ally_target(actor, ability, allies, dead_allies)

	return []


func _pick_enemy_target(actor: BattleUnit, ability: Resource, enemies: Array) -> Array:
	var valid: Array = []
	var melee_reach := false

	if ability.reach == "melee":
		valid = _get_melee_targets(enemies)

		# Chance to reach through front line and target back row
		if not valid.is_empty() and randf() < MELEE_BACKROW_REACH_CHANCE:
			var back := enemies.filter(func(u: BattleUnit) -> bool: return u.is_alive and u.row == "back")

			if not back.is_empty():
				valid.append_array(back)
				melee_reach = true
	else:
		valid = enemies.filter(func(u: BattleUnit) -> bool: return u.is_alive)

	valid = valid.filter(func(u: BattleUnit) -> bool: return u.is_alive and u.current_hp > 0)

	if valid.is_empty():
		return []

	# Taunting enemies must be attacked — game rule, not a strategy
	var taunters := valid.filter(func(u: BattleUnit) -> bool: return u.has_effect("taunt"))

	if not taunters.is_empty():
		return [taunters[0]]

	var ctx := {"actor": actor, "ability": ability, "melee_reach": melee_reach}
	return _apply_strategy(ability.ai_target_strategy, valid, ctx)


func _pick_ally_target(actor: BattleUnit, ability: Resource, allies: Array, dead_allies: Array) -> Array:
	var strategy: String = ability.ai_target_strategy

	# "first_dead" targets the dead pool, everything else targets living allies
	var candidates: Array = []

	if strategy == "first_dead":
		candidates = dead_allies
	else:
		candidates = allies.filter(func(u: BattleUnit) -> bool: return u.is_alive)

	var ctx := {"actor": actor, "ability": ability, "melee_reach": false}
	return _apply_strategy(strategy, candidates, ctx)


func _apply_strategy(strategy: String, candidates: Array, ctx: Dictionary) -> Array:
	if candidates.is_empty():
		return []

	var selector: Callable = _target_strategy_registry.get(strategy)

	if selector == null:
		push_warning("Unknown AI target strategy: %s — falling back to first" % strategy)
		return [candidates[0]]

	return selector.call(candidates, ctx)


# -- Built-in target strategies --

func _register_default_strategies() -> void:
	_target_strategy_registry["weighted_random"] = func(candidates: Array, ctx: Dictionary) -> Array:
		var result := _weighted_random_target(candidates, ctx.get("melee_reach", false))
		return [result] if result != null else []

	_target_strategy_registry["lowest_hp"] = func(candidates: Array, _ctx: Dictionary) -> Array:
		var lowest: BattleUnit = candidates[0]

		for unit: BattleUnit in candidates:
			if unit.current_hp < lowest.current_hp:
				lowest = unit

		return [lowest]

	_target_strategy_registry["lowest_hp_pct"] = func(candidates: Array, _ctx: Dictionary) -> Array:
		var lowest: BattleUnit = candidates[0]
		var lowest_pct := float(lowest.current_hp) / float(lowest.max_hp)

		for unit: BattleUnit in candidates:
			var pct := float(unit.current_hp) / float(unit.max_hp)

			if pct < lowest_pct:
				lowest = unit
				lowest_pct = pct

		return [lowest]

	_target_strategy_registry["has_negative_effect"] = func(candidates: Array, _ctx: Dictionary) -> Array:
		for unit: BattleUnit in candidates:
			if unit.has_negative_effect():
				return [unit]

		return []

	_target_strategy_registry["front_row"] = func(candidates: Array, _ctx: Dictionary) -> Array:
		for unit: BattleUnit in candidates:
			if unit.row == "front":
				return [unit]

		return [candidates[0]]

	_target_strategy_registry["first_dead"] = func(candidates: Array, _ctx: Dictionary) -> Array:
		return [candidates[0]] if not candidates.is_empty() else []


# -- Melee helpers --

func _get_melee_targets(enemies: Array) -> Array:
	var front := enemies.filter(func(u: BattleUnit) -> bool: return u.is_alive and u.row == "front")

	if not front.is_empty():
		return front

	return enemies.filter(func(u: BattleUnit) -> bool: return u.is_alive)


func _find_basic_attack(actor: BattleUnit) -> Resource:
	for ab: Resource in actor.abilities:
		if ab.id == "basic_attack":
			return ab

	return null


func _weighted_random_target(targets: Array, melee_reach: bool = false) -> BattleUnit:
	if targets.size() == 1:
		return targets[0]

	var weights: Array[float] = []

	for target: BattleUnit in targets:
		var damage_ratio := 1.0 - (float(target.current_hp) / float(target.max_hp))
		var weight := 1.0 + damage_ratio * FOCUS_FIRE_WEIGHT

		if melee_reach and target.row == "back":
			weight *= MELEE_BACKROW_WEIGHT

		weights.append(weight)

	var total_weight := 0.0

	for w: float in weights:
		total_weight += w

	var roll := randf() * total_weight
	var cumulative := 0.0

	for i in range(targets.size()):
		cumulative += weights[i]

		if roll <= cumulative:
			return targets[i]

	return targets[-1]
