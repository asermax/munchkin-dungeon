extends GutTest

## Tests for BattleUnit — state holder with HP, cooldowns, effects, boss phases.

var _unit: BattleUnit


func before_each() -> void:
	_unit = TestFactory.make_hero_unit()


# -- from_hero / from_monster factories --

func test_from_hero_sets_identity() -> void:
	assert_eq(_unit.is_hero, true)
	assert_eq(_unit.side, "hero")
	assert_eq(_unit.row, "front")
	assert_eq(_unit.slot, 0)
	assert_true(_unit.unit_id.length() > 0)


func test_from_hero_computes_stats() -> void:
	# Default factory: level 1, base 5 all stats, no equipment
	assert_eq(_unit.max_hp, 50 + 5 * 8)
	assert_eq(_unit.damage, 5 * 2)
	assert_eq(_unit.current_hp, _unit.max_hp)
	assert_true(_unit.is_alive)


func test_from_monster_sets_identity() -> void:
	var monster := TestFactory.make_monster_unit()

	assert_eq(monster.is_hero, false)
	assert_eq(monster.side, "enemy")


func test_from_monster_uses_flat_stats() -> void:
	var data := TestFactory.make_monster_data({"max_hp": 80, "damage": 15, "defense": 5})
	var monster := TestFactory.make_monster_unit({"monster_data": data})

	assert_eq(monster.max_hp, 80)
	assert_eq(monster.damage, 15)
	assert_eq(monster.defense, 5)
	assert_eq(monster.current_hp, 80)


# -- take_damage --

func test_take_damage_normal() -> void:
	var taken := _unit.take_damage(10)

	assert_eq(taken, 10)
	assert_eq(_unit.current_hp, _unit.max_hp - 10)
	assert_true(_unit.is_alive)


func test_take_damage_kills_at_zero() -> void:
	_unit.take_damage(_unit.max_hp)

	assert_eq(_unit.current_hp, 0)
	assert_false(_unit.is_alive)


func test_take_damage_overkill_clamps() -> void:
	var taken := _unit.take_damage(_unit.max_hp + 100)

	assert_eq(taken, _unit.max_hp, "actual damage clamped to current_hp")
	assert_eq(_unit.current_hp, 0)
	assert_false(_unit.is_alive)


# -- heal --

func test_heal_normal() -> void:
	_unit.take_damage(20)
	var healed := _unit.heal(10)

	assert_eq(healed, 10)
	assert_eq(_unit.current_hp, _unit.max_hp - 10)


func test_heal_capped_at_max_hp() -> void:
	_unit.take_damage(5)
	var healed := _unit.heal(100)

	assert_eq(healed, 5, "heal capped at missing HP")
	assert_eq(_unit.current_hp, _unit.max_hp)


func test_heal_at_full_hp() -> void:
	var healed := _unit.heal(10)

	assert_eq(healed, 0)


# -- cooldowns --

func test_use_ability_sets_cooldown() -> void:
	_unit.use_ability("fireball", 3)

	assert_false(_unit.is_ability_ready("fireball"))


func test_ability_ready_when_no_cooldown() -> void:
	assert_true(_unit.is_ability_ready("fireball"))


func test_tick_cooldowns_decrements() -> void:
	_unit.use_ability("fireball", 2)
	_unit.tick_cooldowns()

	assert_false(_unit.is_ability_ready("fireball"), "still on cooldown after 1 tick")

	_unit.tick_cooldowns()

	assert_true(_unit.is_ability_ready("fireball"), "ready after 2 ticks")


func test_use_ability_zero_cooldown_no_entry() -> void:
	_unit.use_ability("basic_attack", 0)

	assert_true(_unit.is_ability_ready("basic_attack"), "0 cooldown means always ready")


# -- effects --

func test_apply_effect_defense_up() -> void:
	var base_defense := _unit.defense
	_unit.apply_effect("shield", "Shield", 3, 5, "defense_up")

	assert_eq(_unit.defense, base_defense + 5)
	assert_true(_unit.has_effect("defense_up"))


func test_apply_effect_dodge_up() -> void:
	var base_dodge := _unit.dodge_chance
	_unit.apply_effect("evasion", "Evasion", 2, 10, "dodge_up")

	# dodge_up scale is 0.01, so value 10 → +0.10
	assert_almost_eq(_unit.dodge_chance, base_dodge + 0.10, 0.001)


func test_apply_effect_damage_up() -> void:
	var base_damage := _unit.damage
	_unit.apply_effect("rage", "Rage", 2, 5, "damage_up")

	assert_eq(_unit.damage, base_damage + 5)


func test_remove_effect_reverts_stats() -> void:
	var base_defense := _unit.defense
	_unit.apply_effect("shield", "Shield", 3, 5, "defense_up")
	_unit.remove_effect(0)

	assert_eq(_unit.defense, base_defense, "defense reverted after removal")
	assert_false(_unit.has_effect("defense_up"))


func test_tick_effects_dot_damage() -> void:
	_unit.apply_effect("bleed_1", "Bleed", 2, 3, "bleed")
	var hp_before := _unit.current_hp

	var results := _unit.tick_effects()

	assert_eq(_unit.current_hp, hp_before - 3, "bleed deals damage")
	assert_eq(results.size(), 1)
	assert_eq(results[0].effect, "bleed")
	assert_eq(results[0].damage, 3)


func test_tick_effects_expires_after_duration() -> void:
	_unit.apply_effect("poison_1", "Poison", 1, 2, "poison")

	_unit.tick_effects()

	assert_false(_unit.has_effect("poison"), "effect removed after duration expires")


func test_has_negative_effect() -> void:
	assert_false(_unit.has_negative_effect())

	_unit.apply_effect("stun_1", "Stun", 1, 0, "stun")

	assert_true(_unit.has_negative_effect())


func test_is_stunned() -> void:
	assert_false(_unit.is_stunned())

	_unit.apply_effect("stun_1", "Stun", 1, 0, "stun")

	assert_true(_unit.is_stunned())


func test_non_buff_effect_doesnt_change_stats() -> void:
	var base_defense := _unit.defense
	_unit.apply_effect("bleed_1", "Bleed", 2, 5, "bleed")

	assert_eq(_unit.defense, base_defense, "bleed should not change defense")


# -- boss phase 2 --

func test_check_phase2_non_boss_returns_false() -> void:
	assert_false(_unit.check_phase2(), "non-boss can't enter phase 2")


func test_check_phase2_boss_above_threshold() -> void:
	var boss := TestFactory.make_monster_unit({
		"monster_data": TestFactory.make_monster_data({
			"is_boss": true,
			"max_hp": 100,
			"phase2_hp_percent": 0.5,
			"phase2_stat_multiplier": 1.5,
		}),
	})

	assert_false(boss.check_phase2(), "boss above 50% HP shouldn't enter phase 2")


func test_check_phase2_boss_at_threshold() -> void:
	var phase2_ability := TestFactory.make_ability({"id": "rage_mode", "display_name": "Rage Mode"})
	var boss := TestFactory.make_monster_unit({
		"monster_data": TestFactory.make_monster_data({
			"is_boss": true,
			"max_hp": 100,
			"damage": 20,
			"defense": 10,
			"phase2_hp_percent": 0.5,
			"phase2_stat_multiplier": 1.5,
			"phase2_abilities": [phase2_ability],
		}),
	})

	boss.take_damage(50)
	var transitioned := boss.check_phase2()

	assert_true(transitioned, "boss at 50% should enter phase 2")
	assert_true(boss.is_in_phase2)
	assert_eq(boss.damage, floori(20 * 1.5), "damage boosted by multiplier")
	assert_eq(boss.defense, floori(10 * 1.5), "defense boosted by multiplier")


func test_check_phase2_only_triggers_once() -> void:
	var boss := TestFactory.make_monster_unit({
		"monster_data": TestFactory.make_monster_data({
			"is_boss": true,
			"max_hp": 100,
			"phase2_hp_percent": 0.5,
			"phase2_stat_multiplier": 1.5,
		}),
	})

	boss.take_damage(60)
	boss.check_phase2()

	assert_false(boss.check_phase2(), "second check should return false")


# -- get_display_info --

func test_get_display_info_returns_expected_keys() -> void:
	var info := _unit.get_display_info()

	assert_has(info, "unit_id")
	assert_has(info, "display_name")
	assert_has(info, "is_hero")
	assert_has(info, "current_hp")
	assert_has(info, "max_hp")
	assert_has(info, "is_alive")
	assert_has(info, "is_boss")
