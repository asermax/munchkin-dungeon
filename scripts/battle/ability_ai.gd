class_name AbilityAI
extends RefCounted

## Evaluates priority trees to pick the best action for auto-battle.
## Walks the unit's ability list (ordered by ai_priority descending),
## picks the first whose condition is met and cooldown is ready.

var _basic_attack: Resource     # fallback AbilityData


func setup(basic_attack: Resource) -> void:
	_basic_attack = basic_attack


func choose_action(actor: BattleUnit, allies: Array, enemies: Array, dead_allies: Array) -> Dictionary:
	## Returns {ability: Resource, targets: Array[BattleUnit]}

	for ab: Resource in actor.abilities:
		# Skip basic attack in the priority loop — it's the fallback
		if ab.id == "basic_attack":
			continue

		if not actor.is_ability_ready(ab.id):
			continue

		if not _check_condition(ab.ai_condition, actor, allies, enemies, dead_allies):
			continue

		var targets := _select_targets(actor, ab, allies, enemies, dead_allies)

		if targets.is_empty():
			continue

		return {"ability": ab, "targets": targets}

	# Fallback: basic attack
	var basic := _basic_attack if _basic_attack != null else _find_basic_attack(actor)
	var basic_targets := _select_targets(actor, basic, allies, enemies, dead_allies)

	return {"ability": basic, "targets": basic_targets}


func _check_condition(condition: String, actor: BattleUnit, allies: Array, enemies: Array, dead_allies: Array) -> bool:
	match condition:
		"always":
			return true

		"ally_below_40":
			for ally: BattleUnit in allies:
				if ally.is_alive and float(ally.current_hp) / float(ally.max_hp) < 0.4:
					return true
			return false

		"enemy_below_20":
			for enemy: BattleUnit in enemies:
				if enemy.is_alive and float(enemy.current_hp) / float(enemy.max_hp) < 0.2:
					return true
			return false

		"self_below_30":
			return float(actor.current_hp) / float(actor.max_hp) < 0.3

		"self_below_50":
			return float(actor.current_hp) / float(actor.max_hp) < 0.5

		"enemies_gte_3":
			var alive_count := 0
			for enemy: BattleUnit in enemies:
				if enemy.is_alive:
					alive_count += 1
			return alive_count >= 3

		"ally_cursed":
			for ally: BattleUnit in allies:
				if ally.is_alive and ally.has_negative_effect():
					return true
			return false

		"ally_dead":
			return not dead_allies.is_empty()

	return false


func _select_targets(actor: BattleUnit, ability: Resource, allies: Array, enemies: Array, dead_allies: Array) -> Array:
	match ability.target_type:
		"enemy":
			var target := _pick_enemy_target(actor, ability, enemies)
			return [target] if target != null else []

		"ally":
			if ability.effect_type == "resurrect":
				return [dead_allies[0]] if not dead_allies.is_empty() else []

			var target := _pick_ally_target(ability, allies)
			return [target] if target != null else []

		"self":
			return [actor]

		"all_enemies":
			if ability.reach == "melee":
				return _get_melee_targets(enemies)

			return enemies.filter(func(u: BattleUnit) -> bool: return u.is_alive)

		"all_allies":
			return allies.filter(func(u: BattleUnit) -> bool: return u.is_alive)

	return []


func _pick_enemy_target(actor: BattleUnit, ability: Resource, enemies: Array) -> BattleUnit:
	var valid: Array = []

	if ability.reach == "melee":
		valid = _get_melee_targets(enemies)
	else:
		valid = enemies.filter(func(u: BattleUnit) -> bool: return u.is_alive)

	# Extra safety: ensure all candidates are alive (handles mid-round deaths)
	valid = valid.filter(func(u: BattleUnit) -> bool: return u.is_alive and u.current_hp > 0)

	if valid.is_empty():
		return null

	# Check for taunting enemies first — must attack them
	var taunters := valid.filter(func(u: BattleUnit) -> bool: return u.has_effect("taunt"))

	if not taunters.is_empty():
		return taunters[0]

	# For execute-type abilities, pick the lowest HP target
	if ability.ai_condition == "enemy_below_20":
		var lowest: BattleUnit = valid[0]
		for enemy: BattleUnit in valid:
			if enemy.current_hp < lowest.current_hp:
				lowest = enemy
		return lowest

	# Default: pick the enemy with lowest current HP (focus fire)
	var target: BattleUnit = valid[0]
	for enemy: BattleUnit in valid:
		if enemy.current_hp < target.current_hp:
			target = enemy

	return target


func _pick_ally_target(ability: Resource, allies: Array) -> BattleUnit:
	var living := allies.filter(func(u: BattleUnit) -> bool: return u.is_alive)

	if living.is_empty():
		return null

	# Heal: pick ally with lowest HP percentage
	if ability.effect_type == "heal":
		var target: BattleUnit = living[0]
		for ally: BattleUnit in living:
			var ally_pct := float(ally.current_hp) / float(ally.max_hp)
			var target_pct := float(target.current_hp) / float(target.max_hp)
			if ally_pct < target_pct:
				target = ally
		return target

	# Purify: pick ally with negative effects
	if ability.secondary_effect == "cleanse":
		for ally: BattleUnit in living:
			if ally.has_negative_effect():
				return ally
		return null

	# Buff: pick the front-row ally (tanks benefit most)
	for ally: BattleUnit in living:
		if ally.row == "front":
			return ally

	return living[0]


func _get_melee_targets(enemies: Array) -> Array:
	## Melee hits front row. If front row empty, hit back row.
	var front := enemies.filter(func(u: BattleUnit) -> bool: return u.is_alive and u.row == "front")

	if not front.is_empty():
		return front

	return enemies.filter(func(u: BattleUnit) -> bool: return u.is_alive)


func _find_basic_attack(actor: BattleUnit) -> Resource:
	for ab: Resource in actor.abilities:
		if ab.id == "basic_attack":
			return ab

	return null
