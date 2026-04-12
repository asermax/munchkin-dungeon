class_name BattleAction
extends RefCounted

## Represents a single action chosen by an actor during their turn.
## Wraps ability + targets and provides serialization for LLM integration.

var actor: BattleUnit
var ability: Resource         # AbilityData
var targets: Array            # Array[BattleUnit]


static func create(p_actor: BattleUnit, p_ability: Resource, p_targets: Array) -> BattleAction:
	var action := BattleAction.new()
	action.actor = p_actor
	action.ability = p_ability
	action.targets = p_targets
	return action


func is_valid() -> bool:
	return ability != null and not targets.is_empty()


func execute(resolver: AbilityResolver, source_pool: Array) -> Array[Dictionary]:
	return resolver.resolve(actor, targets, ability, source_pool)


func serialize() -> Dictionary:
	return {
		"actor_id": actor.unit_id,
		"actor_name": actor.display_name,
		"ability_id": ability.id,
		"ability_name": ability.display_name,
		"target_ids": targets.map(func(t: BattleUnit) -> String: return t.unit_id),
	}


static func deserialize(
	data: Dictionary,
	find_unit_fn: Callable,
	find_ability_fn: Callable,
) -> BattleAction:
	var actor: BattleUnit = find_unit_fn.call(data.get("actor_id", ""))

	if actor == null:
		return null

	var ability: Resource = find_ability_fn.call(data.get("ability_id", ""))

	if ability == null:
		return null

	var targets: Array = []

	for tid: String in data.get("target_ids", []):
		var unit: BattleUnit = find_unit_fn.call(tid)

		if unit != null:
			targets.append(unit)

	return BattleAction.create(actor, ability, targets)
