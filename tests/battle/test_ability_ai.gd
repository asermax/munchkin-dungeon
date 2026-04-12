extends GutTest

## Tests for AbilityAI — AI decision tree and target selection.

var _ai: AbilityAI
var _actor: BattleUnit
var _allies: Array
var _enemies: Array
var _dead_allies: Array


func before_each() -> void:
	seed(42)

	_ai = AbilityAI.new()
	_ai.setup(TestFactory.make_basic_attack())

	_actor = TestFactory.make_hero_unit()
	_actor.damage = 20
	_actor.abilities = [TestFactory.make_basic_attack()]

	_allies = [_actor]
	_dead_allies = []

	_enemies = [
		_make_enemy("enemy_front_0", "front", 0, 50),
		_make_enemy("enemy_front_1", "front", 1, 50),
	]


func _make_enemy(id: String, row: String, slot: int, hp: int) -> BattleUnit:
	var enemy := TestFactory.make_monster_unit({
		"monster_data": TestFactory.make_monster_data({
			"id": id,
			"max_hp": hp,
			"damage": 10,
			"defense": 0,
			"dodge_chance": 0.0,
		}),
		"row": row,
		"slot": slot,
	})
	return enemy


# -- basic fallback --

func test_choose_action_returns_basic_attack_when_no_specials() -> void:
	var action := _ai.choose_action(_actor, _allies, _enemies, _dead_allies)

	assert_not_null(action)
	assert_eq(action.ability.id, "basic_attack")
	assert_eq(action.targets.size(), 1)


# -- condition: always --

func test_special_ability_with_always_condition() -> void:
	var special := TestFactory.make_ability({
		"id": "power_strike",
		"display_name": "Power Strike",
		"effect_type": "damage",
		"target_type": "enemy",
		"reach": "melee",
		"power": 1.5,
		"ai_priority": 10,
		"ai_condition": TestFactory.make_condition("always"),
	})

	_actor.abilities = [special, TestFactory.make_basic_attack()]

	var action := _ai.choose_action(_actor, _allies, _enemies, _dead_allies)

	assert_eq(action.ability.id, "power_strike", "should pick highest priority available")


# -- condition: self hp_pct --

func test_condition_self_hp_below_threshold() -> void:
	var heal := TestFactory.make_ability({
		"id": "self_heal",
		"effect_type": "heal",
		"target_type": "self",
		"heal_amount": 20,
		"ai_priority": 10,
		"ai_condition": TestFactory.make_condition("self", "hp_pct", "lt", 0.5),
	})

	_actor.abilities = [heal, TestFactory.make_basic_attack()]

	# Above threshold — should use basic attack
	var action := _ai.choose_action(_actor, _allies, _enemies, _dead_allies)
	assert_eq(action.ability.id, "basic_attack")

	# Below threshold — should use heal
	_actor.take_damage(_actor.max_hp * 0.6)
	action = _ai.choose_action(_actor, _allies, _enemies, _dead_allies)
	assert_eq(action.ability.id, "self_heal")


# -- condition: any_ally --

func test_condition_any_ally_hp_below() -> void:
	var ally := TestFactory.make_hero_unit({"row": "back", "slot": 0})
	ally.take_damage(ally.max_hp * 0.7)

	var heal := TestFactory.make_ability({
		"id": "group_heal",
		"effect_type": "heal",
		"target_type": "ally",
		"heal_amount": 15,
		"ai_priority": 10,
		"ai_condition": TestFactory.make_condition("any_ally", "hp_pct", "lt", 0.4),
		"ai_target_strategy": "lowest_hp_pct",
	})

	_actor.abilities = [heal, TestFactory.make_basic_attack()]
	var allies := [_actor, ally]

	var action := _ai.choose_action(_actor, allies, _enemies, _dead_allies)

	assert_eq(action.ability.id, "group_heal")
	assert_eq(action.targets[0], ally, "should target lowest HP ally")


# -- condition: group scope (enemies alive_count) --

func test_condition_enemies_alive_count() -> void:
	var aoe := TestFactory.make_ability({
		"id": "aoe_blast",
		"effect_type": "damage",
		"target_type": "all_enemies",
		"reach": "ranged",
		"power": 0.8,
		"ai_priority": 10,
		"ai_condition": TestFactory.make_condition("enemies", "alive_count", "gte", 3.0),
	})

	_actor.abilities = [aoe, TestFactory.make_basic_attack()]

	# Only 2 enemies — should not trigger
	var action := _ai.choose_action(_actor, _allies, _enemies, _dead_allies)
	assert_eq(action.ability.id, "basic_attack")

	# Add third enemy — should trigger
	_enemies.append(_make_enemy("enemy_back_0", "back", 0, 50))
	action = _ai.choose_action(_actor, _allies, _enemies, _dead_allies)
	assert_eq(action.ability.id, "aoe_blast")


# -- cooldown respect --

func test_skips_ability_on_cooldown() -> void:
	var special := TestFactory.make_ability({
		"id": "power_strike",
		"effect_type": "damage",
		"target_type": "enemy",
		"reach": "melee",
		"power": 1.5,
		"cooldown": 3,
		"ai_priority": 10,
		"ai_condition": TestFactory.make_condition("always"),
	})

	_actor.abilities = [special, TestFactory.make_basic_attack()]
	_actor.use_ability("power_strike", 3)

	var action := _ai.choose_action(_actor, _allies, _enemies, _dead_allies)

	assert_eq(action.ability.id, "basic_attack", "on-cooldown ability should be skipped")


# -- target: self --

func test_target_type_self() -> void:
	var buff := TestFactory.make_ability({
		"id": "war_cry",
		"effect_type": "buff",
		"target_type": "self",
		"secondary_effect": "damage_up",
		"secondary_duration": 3,
		"secondary_value": 5,
		"ai_priority": 10,
		"ai_condition": TestFactory.make_condition("always"),
	})

	_actor.abilities = [buff, TestFactory.make_basic_attack()]
	var action := _ai.choose_action(_actor, _allies, _enemies, _dead_allies)

	assert_eq(action.targets, [_actor])


# -- target: all_enemies --

func test_target_type_all_enemies() -> void:
	var aoe := TestFactory.make_ability({
		"id": "whirlwind",
		"effect_type": "damage",
		"target_type": "all_enemies",
		"reach": "ranged",
		"ai_priority": 10,
		"ai_condition": TestFactory.make_condition("always"),
	})

	_actor.abilities = [aoe, TestFactory.make_basic_attack()]
	var action := _ai.choose_action(_actor, _allies, _enemies, _dead_allies)

	assert_eq(action.targets.size(), 2, "all_enemies should target all living enemies")


# -- target: all_allies --

func test_target_type_all_allies() -> void:
	var ally := TestFactory.make_hero_unit({"row": "back", "slot": 0})
	var allies := [_actor, ally]

	var group_buff := TestFactory.make_ability({
		"id": "group_buff",
		"effect_type": "buff",
		"target_type": "all_allies",
		"secondary_effect": "defense_up",
		"secondary_duration": 2,
		"secondary_value": 3,
		"ai_priority": 10,
		"ai_condition": TestFactory.make_condition("always"),
	})

	_actor.abilities = [group_buff, TestFactory.make_basic_attack()]
	var action := _ai.choose_action(_actor, allies, _enemies, _dead_allies)

	assert_eq(action.targets.size(), 2)


# -- taunt forces target --

func test_taunt_forces_target_selection() -> void:
	_enemies[1].apply_effect("taunt_1", "Taunt", 2, 0, "taunt")

	var action := _ai.choose_action(_actor, _allies, _enemies, _dead_allies)

	assert_eq(action.targets[0], _enemies[1], "must attack taunting enemy")


# -- melee targeting --

func test_melee_prefers_front_row() -> void:
	var back_enemy := _make_enemy("enemy_back_0", "back", 0, 50)
	var enemies_with_back := [_enemies[0], _enemies[1], back_enemy]

	# Run multiple times — melee should mostly hit front row
	var front_hits := 0

	for i in range(20):
		seed(i)
		var action := _ai.choose_action(_actor, _allies, enemies_with_back, _dead_allies)

		if action.targets[0].row == "front":
			front_hits += 1

	assert_gt(front_hits, 10, "melee should preferentially target front row")


func test_melee_can_reach_back_when_front_dead() -> void:
	_enemies[0].is_alive = false
	_enemies[0].current_hp = 0
	_enemies[1].is_alive = false
	_enemies[1].current_hp = 0

	var back_enemy := _make_enemy("enemy_back_0", "back", 0, 50)
	var enemies_with_back := [_enemies[0], _enemies[1], back_enemy]

	var action := _ai.choose_action(_actor, _allies, enemies_with_back, _dead_allies)

	assert_eq(action.targets[0], back_enemy, "melee should reach back when front is dead")


# -- strategy: lowest_hp --

func test_strategy_lowest_hp() -> void:
	_enemies[0].take_damage(30)

	var ability := TestFactory.make_ability({
		"id": "finish_off",
		"effect_type": "damage",
		"target_type": "enemy",
		"reach": "ranged",
		"ai_priority": 10,
		"ai_condition": TestFactory.make_condition("always"),
		"ai_target_strategy": "lowest_hp",
	})

	_actor.abilities = [ability, TestFactory.make_basic_attack()]
	var action := _ai.choose_action(_actor, _allies, _enemies, _dead_allies)

	assert_eq(action.targets[0], _enemies[0], "should pick enemy with lowest current HP")


# -- strategy: first_dead (for resurrect) --

func test_strategy_first_dead() -> void:
	var dead_ally := TestFactory.make_hero_unit({"row": "back", "slot": 1})
	dead_ally.is_alive = false
	dead_ally.current_hp = 0

	var resurrect := TestFactory.make_ability({
		"id": "resurrect",
		"effect_type": "resurrect",
		"target_type": "ally",
		"ai_priority": 10,
		"ai_condition": TestFactory.make_condition("dead_allies", "count", "gte", 1.0),
		"ai_target_strategy": "first_dead",
	})

	_actor.abilities = [resurrect, TestFactory.make_basic_attack()]
	var action := _ai.choose_action(_actor, _allies, _enemies, [dead_ally])

	assert_eq(action.ability.id, "resurrect")
	assert_eq(action.targets[0], dead_ally)


# -- strategy: has_negative_effect (for cleanse) --

func test_strategy_has_negative_effect() -> void:
	var poisoned_ally := TestFactory.make_hero_unit({"row": "back", "slot": 0})
	poisoned_ally.apply_effect("poison_1", "Poison", 3, 5, "poison")

	var cleanse := TestFactory.make_ability({
		"id": "purify",
		"effect_type": "buff",
		"target_type": "ally",
		"secondary_effect": "cleanse",
		"ai_priority": 10,
		"ai_condition": TestFactory.make_condition("any_ally", "has_negative_effect", "eq", 1.0),
		"ai_target_strategy": "has_negative_effect",
	})

	_actor.abilities = [cleanse, TestFactory.make_basic_attack()]
	var allies := [_actor, poisoned_ally]

	var action := _ai.choose_action(_actor, allies, _enemies, _dead_allies)

	assert_eq(action.ability.id, "purify")
	assert_eq(action.targets[0], poisoned_ally)
