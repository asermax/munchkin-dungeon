class_name AbilityResolver
extends RefCounted

## Executes abilities and returns results for the battle log.

const ROW_PENALTY_DODGE_BONUS: float = 0.25
const ROW_PENALTY_DODGE_CAP: float = 0.65
const ROW_PENALTY_DAMAGE_MULTIPLIER: float = 0.75
const RESURRECT_HP_PERCENT: float = 0.1


func resolve(user: BattleUnit, targets: Array, ability: Resource, source_pool: Array = []) -> Array[Dictionary]:
	var results: Array[Dictionary] = []

	match ability.effect_type:
		"damage":
			results = _resolve_damage(user, targets, ability, source_pool)

		"heal":
			results = _resolve_heal(user, targets, ability, source_pool)

		"buff":
			results = _resolve_buff(user, targets, ability, source_pool)

		"debuff":
			results = _resolve_debuff(user, targets, ability, source_pool)

		"taunt":
			results = _resolve_taunt(user, ability)

		"resurrect":
			results = _resolve_resurrect(user, targets, ability)

	# Put ability on cooldown
	user.use_ability(ability.id, ability.cooldown)

	return results


func _resolve_damage(user: BattleUnit, targets: Array, ability: Resource, source_pool: Array) -> Array[Dictionary]:
	var results: Array[Dictionary] = []

	# Determine which damage stat to use
	var attacker_damage: int = user.damage

	if ability.damage_stat == "int":
		attacker_damage = user.magic_damage

	for target: BattleUnit in targets:
		if not target.is_alive:
			var replacement := _find_living_replacement(targets, source_pool)
			if replacement == null:
				continue
			target = replacement

		# Row penalty: melee reaching back row is harder to land and weaker
		# Only applies when the enemy front line is alive to provide cover
		var front_alive := source_pool.any(func(u: BattleUnit) -> bool: return u.is_alive and u.row == "front")
		var row_penalty: bool = ability.reach == "melee" and target.row == "back" and front_alive
		var effective_dodge := target.dodge_chance

		if row_penalty:
			effective_dodge = minf(ROW_PENALTY_DODGE_CAP, target.dodge_chance + ROW_PENALTY_DODGE_BONUS)

		var attack_result := StatCalculator.resolve_attack(
			attacker_damage,
			user.crit_chance,
			user.crit_multiplier,
			user.trait_id,
			target.defense,
			effective_dodge,
			target.trait_id,
			ability.power,
		)

		var result := {
			"type": "damage",
			"actor": user.get_display_info(),
			"target": target.get_display_info(),
			"ability_name": ability.display_name,
			"dodged": attack_result.dodged,
			"crit": attack_result.crit,
			"amount": 0,
			"killed": false,
			"row_penalty": row_penalty,
		}

		if not attack_result.dodged:
			var final_dmg: int = attack_result.final_damage

			if row_penalty:
				final_dmg = maxi(1, floori(final_dmg * ROW_PENALTY_DAMAGE_MULTIPLIER))

			var actual := target.take_damage(final_dmg)
			result.amount = actual
			result.killed = not target.is_alive

			# Apply secondary effect
			if ability.secondary_effect != "" and ability.secondary_chance > 0.0:
				if randf() < ability.secondary_chance:
					_apply_secondary(target, ability)
					result["secondary"] = ability.secondary_effect

			# Life drain: heal attacker
			if ability.secondary_effect == "life_drain" and ability.secondary_value > 0:
				var healed := user.heal(ability.secondary_value)
				result["life_drain"] = healed

		results.append(result)

	return results


func _resolve_heal(user: BattleUnit, targets: Array, ability: Resource, source_pool: Array) -> Array[Dictionary]:
	var results: Array[Dictionary] = []

	for target: BattleUnit in targets:
		if not target.is_alive:
			var replacement := _find_living_replacement(targets, source_pool)
			if replacement == null:
				continue
			target = replacement

		var healed := target.heal(ability.heal_amount)

		results.append({
			"type": "heal",
			"actor": user.get_display_info(),
			"target": target.get_display_info(),
			"ability_name": ability.display_name,
			"amount": healed,
		})

	return results


func _resolve_buff(user: BattleUnit, targets: Array, ability: Resource, source_pool: Array) -> Array[Dictionary]:
	var results: Array[Dictionary] = []

	for target: BattleUnit in targets:
		if not target.is_alive:
			var replacement := _find_living_replacement(targets, source_pool)
			if replacement == null:
				continue
			target = replacement

		# Cleanse: remove negative effects instead of buffing
		if ability.secondary_effect == "cleanse":
			var removed := _cleanse(target)

			results.append({
				"type": "cleanse",
				"actor": user.get_display_info(),
				"target": target.get_display_info(),
				"ability_name": ability.display_name,
				"removed": removed,
			})
			continue

		if ability.secondary_effect != "":
			target.apply_effect(
				ability.id,
				ability.secondary_effect,
				ability.secondary_duration,
				ability.secondary_value,
				ability.secondary_effect,
			)

		results.append({
			"type": "buff",
			"actor": user.get_display_info(),
			"target": target.get_display_info(),
			"ability_name": ability.display_name,
			"effect": ability.secondary_effect,
			"duration": ability.secondary_duration,
		})

	return results


func _resolve_debuff(user: BattleUnit, targets: Array, ability: Resource, source_pool: Array) -> Array[Dictionary]:
	var results: Array[Dictionary] = []

	for target: BattleUnit in targets:
		if not target.is_alive:
			var replacement := _find_living_replacement(targets, source_pool)
			if replacement == null:
				continue
			target = replacement

		if ability.secondary_effect != "":
			target.apply_effect(
				ability.id,
				ability.secondary_effect,
				ability.secondary_duration,
				ability.secondary_value,
				ability.secondary_effect,
			)

		results.append({
			"type": "debuff",
			"actor": user.get_display_info(),
			"target": target.get_display_info(),
			"ability_name": ability.display_name,
			"effect": ability.secondary_effect,
			"duration": ability.secondary_duration,
		})

	return results


func _resolve_taunt(user: BattleUnit, ability: Resource) -> Array[Dictionary]:
	user.apply_effect(
		ability.id, "taunt",
		ability.secondary_duration, 0, "taunt",
	)

	return [{
		"type": "taunt",
		"actor": user.get_display_info(),
		"target": user.get_display_info(),
		"ability_name": ability.display_name,
		"duration": ability.secondary_duration,
	}]


func _resolve_resurrect(user: BattleUnit, targets: Array, ability: Resource) -> Array[Dictionary]:
	if targets.is_empty():
		return []

	var target: BattleUnit = targets[0]
	target.is_alive = true

	var revive_hp := maxi(1, floori(target.max_hp * RESURRECT_HP_PERCENT))
	target.current_hp = revive_hp

	return [{
		"type": "resurrect",
		"actor": user.get_display_info(),
		"target": target.get_display_info(),
		"ability_name": ability.display_name,
		"amount": revive_hp,
	}]


func _find_living_replacement(current_targets: Array, source_pool: Array) -> BattleUnit:
	var candidates := source_pool.filter(func(u: BattleUnit) -> bool:
		return u.is_alive and not current_targets.has(u)
	)

	if candidates.is_empty():
		return null

	return candidates[randi() % candidates.size()]


func _apply_secondary(target: BattleUnit, ability: Resource) -> void:
	target.apply_effect(
		ability.id,
		ability.secondary_effect,
		ability.secondary_duration,
		ability.secondary_value,
		ability.secondary_effect,
	)


func _cleanse(target: BattleUnit) -> int:
	var negative_types := ["bleed", "poison", "stun", "accuracy_down"]
	var removed := 0
	var to_remove: Array[int] = []

	for i in range(target.active_effects.size()):
		if target.active_effects[i].type in negative_types:
			to_remove.append(i)
			removed += 1

	to_remove.reverse()

	for i: int in to_remove:
		target.remove_effect(i)

	return removed
