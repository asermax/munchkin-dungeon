extends GutTest

## Tests for AbilityResolver — executes abilities through the damage/heal/buff pipeline.

var _resolver: AbilityResolver
var _attacker: BattleUnit
var _defender: BattleUnit
var _pool: Array


func before_each() -> void:
	seed(42)

	_resolver = AbilityResolver.new()

	_attacker = TestFactory.make_hero_unit()
	_attacker.damage = 20
	_attacker.crit_chance = 0.0
	_attacker.crit_multiplier = 2.0
	_attacker.trait_id = ""

	_defender = TestFactory.make_monster_unit({
		"monster_data": TestFactory.make_monster_data({
			"max_hp": 100,
			"damage": 10,
			"defense": 0,
			"dodge_chance": 0.0,
		}),
	})

	_pool = [_attacker, _defender]


# -- damage --

func test_resolve_damage_basic() -> void:
	var ability := TestFactory.make_ability({
		"effect_type": "damage",
		"power": 1.0,
		"reach": "melee",
	})

	var results := _resolver.resolve(_attacker, [_defender], ability, _pool)

	assert_eq(results.size(), 1)
	assert_eq(results[0].type, "damage")
	assert_false(results[0].dodged)
	assert_eq(results[0].amount, 20)


func test_resolve_damage_with_power_multiplier() -> void:
	var ability := TestFactory.make_ability({
		"effect_type": "damage",
		"power": 1.5,
	})

	var results := _resolver.resolve(_attacker, [_defender], ability, _pool)

	assert_eq(results[0].amount, 30)


func test_resolve_damage_dodge() -> void:
	_defender.dodge_chance = 1.0
	var ability := TestFactory.make_ability({"effect_type": "damage"})

	var results := _resolver.resolve(_attacker, [_defender], ability, _pool)

	assert_true(results[0].dodged)
	assert_eq(results[0].amount, 0)


func test_resolve_damage_crit() -> void:
	_attacker.crit_chance = 1.0
	var ability := TestFactory.make_ability({"effect_type": "damage"})

	var results := _resolver.resolve(_attacker, [_defender], ability, _pool)

	assert_true(results[0].crit)
	assert_eq(results[0].amount, 40, "20 * 2.0 crit multiplier")


func test_resolve_damage_kills_target() -> void:
	_defender.current_hp = 10
	var ability := TestFactory.make_ability({"effect_type": "damage"})

	var results := _resolver.resolve(_attacker, [_defender], ability, _pool)

	assert_true(results[0].killed)
	assert_false(_defender.is_alive)


func test_resolve_damage_row_penalty_melee_to_back_with_front_alive() -> void:
	var front_enemy := TestFactory.make_monster_unit({
		"monster_data": TestFactory.make_monster_data({"id": "front_guard"}),
		"row": "front", "slot": 0,
	})
	var back_enemy := TestFactory.make_monster_unit({
		"monster_data": TestFactory.make_monster_data({
			"id": "back_caster",
			"max_hp": 100,
			"defense": 0,
			"dodge_chance": 0.0,
		}),
		"row": "back", "slot": 0,
	})

	var ability := TestFactory.make_ability({
		"effect_type": "damage",
		"reach": "melee",
		"power": 1.0,
	})

	var pool := [_attacker, front_enemy, back_enemy]

	# Row penalty adds 0.25 dodge bonus, so we need a seed where dodge doesn't trigger
	# Try seeds until we find a non-dodge result
	var results: Array[Dictionary] = []

	for i in range(100):
		seed(i)
		back_enemy.current_hp = back_enemy.max_hp
		back_enemy.is_alive = true
		results = _resolver.resolve(_attacker, [back_enemy], ability, pool)

		if not results[0].dodged:
			break

	# Row penalty: damage * 0.75 = 20 * 0.75 = 15
	assert_true(results[0].row_penalty)
	assert_false(results[0].dodged)
	assert_eq(results[0].amount, 15)


func test_resolve_damage_no_row_penalty_ranged() -> void:
	var back_enemy := TestFactory.make_monster_unit({
		"monster_data": TestFactory.make_monster_data({
			"id": "back_caster",
			"max_hp": 100,
			"defense": 0,
			"dodge_chance": 0.0,
		}),
		"row": "back", "slot": 0,
	})
	var front_enemy := TestFactory.make_monster_unit({
		"row": "front", "slot": 0,
	})

	var ability := TestFactory.make_ability({
		"effect_type": "damage",
		"reach": "ranged",
		"power": 1.0,
	})

	var pool := [_attacker, front_enemy, back_enemy]
	var results := _resolver.resolve(_attacker, [back_enemy], ability, pool)

	assert_false(results[0].row_penalty)
	assert_eq(results[0].amount, 20)


func test_resolve_damage_secondary_effect_guaranteed() -> void:
	var ability := TestFactory.make_ability({
		"effect_type": "damage",
		"secondary_effect": "bleed",
		"secondary_chance": 1.0,
		"secondary_duration": 3,
		"secondary_value": 5,
	})

	_resolver.resolve(_attacker, [_defender], ability, _pool)

	assert_true(_defender.has_effect("bleed"))


func test_resolve_damage_secondary_effect_zero_chance() -> void:
	var ability := TestFactory.make_ability({
		"effect_type": "damage",
		"secondary_effect": "stun",
		"secondary_chance": 0.0,
		"secondary_duration": 1,
		"secondary_value": 0,
	})

	_resolver.resolve(_attacker, [_defender], ability, _pool)

	assert_false(_defender.has_effect("stun"))


func test_resolve_damage_life_drain() -> void:
	_attacker.take_damage(30)
	var hp_before := _attacker.current_hp

	var ability := TestFactory.make_ability({
		"effect_type": "damage",
		"secondary_effect": "life_drain",
		"secondary_chance": 1.0,
		"secondary_value": 10,
	})

	var results := _resolver.resolve(_attacker, [_defender], ability, _pool)

	assert_gt(_attacker.current_hp, hp_before, "life drain should heal attacker")
	assert_has(results[0], "life_drain")


func test_resolve_damage_dead_target_replacement() -> void:
	_defender.is_alive = false
	_defender.current_hp = 0

	var alive_enemy := TestFactory.make_monster_unit({
		"monster_data": TestFactory.make_monster_data({
			"id": "alive_enemy",
			"max_hp": 100,
			"defense": 0,
			"dodge_chance": 0.0,
		}),
		"row": "front", "slot": 1,
	})

	var ability := TestFactory.make_ability({"effect_type": "damage"})
	var pool := [_attacker, _defender, alive_enemy]

	var results := _resolver.resolve(_attacker, [_defender], ability, pool)

	assert_eq(results.size(), 1)
	assert_eq(results[0].target.unit_id, alive_enemy.unit_id, "should redirect to living target")


# -- heal --

func test_resolve_heal() -> void:
	_attacker.take_damage(30)
	var ability := TestFactory.make_ability({
		"effect_type": "heal",
		"target_type": "ally",
		"heal_amount": 20,
	})

	var results := _resolver.resolve(_attacker, [_attacker], ability, _pool)

	assert_eq(results.size(), 1)
	assert_eq(results[0].type, "heal")
	assert_eq(results[0].amount, 20)


func test_resolve_heal_capped_at_max() -> void:
	_attacker.take_damage(5)
	var ability := TestFactory.make_ability({
		"effect_type": "heal",
		"heal_amount": 100,
	})

	var results := _resolver.resolve(_attacker, [_attacker], ability, _pool)

	assert_eq(results[0].amount, 5, "heal capped at missing HP")


# -- buff --

func test_resolve_buff_applies_effect() -> void:
	var ability := TestFactory.make_ability({
		"effect_type": "buff",
		"target_type": "ally",
		"secondary_effect": "defense_up",
		"secondary_duration": 3,
		"secondary_value": 5,
	})

	var results := _resolver.resolve(_attacker, [_attacker], ability, _pool)

	assert_eq(results[0].type, "buff")
	assert_true(_attacker.has_effect("defense_up"))


func test_resolve_buff_cleanse() -> void:
	_attacker.apply_effect("bleed_1", "Bleed", 3, 5, "bleed")
	_attacker.apply_effect("poison_1", "Poison", 2, 3, "poison")

	var ability := TestFactory.make_ability({
		"effect_type": "buff",
		"secondary_effect": "cleanse",
	})

	var results := _resolver.resolve(_attacker, [_attacker], ability, _pool)

	assert_eq(results[0].type, "cleanse")
	assert_false(_attacker.has_effect("bleed"))
	assert_false(_attacker.has_effect("poison"))


# -- debuff --

func test_resolve_debuff_applies_effect() -> void:
	var ability := TestFactory.make_ability({
		"effect_type": "debuff",
		"secondary_effect": "accuracy_down",
		"secondary_duration": 2,
		"secondary_value": 3,
	})

	var results := _resolver.resolve(_attacker, [_defender], ability, _pool)

	assert_eq(results[0].type, "debuff")
	assert_true(_defender.has_effect("accuracy_down"))


# -- taunt --

func test_resolve_taunt_applies_to_self() -> void:
	var ability := TestFactory.make_ability({
		"effect_type": "taunt",
		"target_type": "self",
		"secondary_effect": "taunt",
		"secondary_duration": 2,
		"secondary_value": 0,
	})

	var results := _resolver.resolve(_attacker, [_attacker], ability, _pool)

	assert_eq(results[0].type, "taunt")
	assert_true(_attacker.has_effect("taunt"))


# -- resurrect --

func test_resolve_resurrect_revives_at_10_percent() -> void:
	var dead_hero := TestFactory.make_hero_unit({"row": "back", "slot": 1})
	dead_hero.is_alive = false
	dead_hero.current_hp = 0

	var ability := TestFactory.make_ability({
		"effect_type": "resurrect",
		"target_type": "ally",
	})

	var results := _resolver.resolve(_attacker, [dead_hero], ability, _pool)

	assert_eq(results[0].type, "resurrect")
	assert_true(dead_hero.is_alive)

	var expected_hp := maxi(1, floori(dead_hero.max_hp * 0.1))
	assert_eq(dead_hero.current_hp, expected_hp)


# -- cooldown --

func test_resolve_sets_ability_cooldown() -> void:
	var ability := TestFactory.make_ability({
		"effect_type": "damage",
		"cooldown": 3,
		"id": "fireball",
	})

	_resolver.resolve(_attacker, [_defender], ability, _pool)

	assert_false(_attacker.is_ability_ready("fireball"), "ability should be on cooldown")
