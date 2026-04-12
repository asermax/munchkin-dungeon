extends GutTest

## Tests for BattleAction — command pattern with serialization.

var _actor: BattleUnit
var _target: BattleUnit
var _ability: AbilityData


func before_each() -> void:
	_actor = TestFactory.make_hero_unit()
	_target = TestFactory.make_monster_unit()
	_ability = TestFactory.make_basic_attack()


# -- create / is_valid --

func test_create_sets_fields() -> void:
	var action := BattleAction.create(_actor, _ability, [_target])

	assert_eq(action.actor, _actor)
	assert_eq(action.ability, _ability)
	assert_eq(action.targets.size(), 1)
	assert_eq(action.targets[0], _target)


func test_is_valid_with_ability_and_targets() -> void:
	var action := BattleAction.create(_actor, _ability, [_target])

	assert_true(action.is_valid())


func test_is_valid_false_with_null_ability() -> void:
	var action := BattleAction.create(_actor, null, [_target])

	assert_false(action.is_valid())


func test_is_valid_false_with_empty_targets() -> void:
	var action := BattleAction.create(_actor, _ability, [])

	assert_false(action.is_valid())


# -- serialize --

func test_serialize_structure() -> void:
	var action := BattleAction.create(_actor, _ability, [_target])
	var data := action.serialize()

	assert_has(data, "actor_id")
	assert_has(data, "actor_name")
	assert_has(data, "ability_id")
	assert_has(data, "ability_name")
	assert_has(data, "target_ids")
	assert_eq(data.actor_id, _actor.unit_id)
	assert_eq(data.ability_id, "basic_attack")
	assert_eq(data.target_ids.size(), 1)


# -- deserialize round-trip --

func test_deserialize_round_trip() -> void:
	var action := BattleAction.create(_actor, _ability, [_target])
	var data := action.serialize()

	var find_unit := func(id: String) -> BattleUnit:
		if id == _actor.unit_id:
			return _actor
		if id == _target.unit_id:
			return _target
		return null

	var find_ability := func(_id: String) -> Resource:
		return _ability

	var restored := BattleAction.deserialize(data, find_unit, find_ability)

	assert_not_null(restored)
	assert_eq(restored.actor, _actor)
	assert_eq(restored.ability, _ability)
	assert_eq(restored.targets.size(), 1)
	assert_eq(restored.targets[0], _target)


func test_deserialize_null_actor_returns_null() -> void:
	var data := {"actor_id": "missing", "ability_id": "basic_attack", "target_ids": []}

	var find_unit := func(_id: String) -> BattleUnit:
		return null

	var find_ability := func(_id: String) -> Resource:
		return _ability

	var restored := BattleAction.deserialize(data, find_unit, find_ability)

	assert_null(restored)


func test_deserialize_null_ability_returns_null() -> void:
	var data := {"actor_id": _actor.unit_id, "ability_id": "missing", "target_ids": []}

	var find_unit := func(id: String) -> BattleUnit:
		if id == _actor.unit_id:
			return _actor
		return null

	var find_ability := func(_id: String) -> Resource:
		return null

	var restored := BattleAction.deserialize(data, find_unit, find_ability)

	assert_null(restored)


func test_deserialize_skips_null_targets() -> void:
	var data := {
		"actor_id": _actor.unit_id,
		"ability_id": "basic_attack",
		"target_ids": ["missing_1", "missing_2"],
	}

	var find_unit := func(id: String) -> BattleUnit:
		if id == _actor.unit_id:
			return _actor
		return null

	var find_ability := func(_id: String) -> Resource:
		return _ability

	var restored := BattleAction.deserialize(data, find_unit, find_ability)

	assert_not_null(restored)
	assert_eq(restored.targets.size(), 0, "null targets should be excluded")
