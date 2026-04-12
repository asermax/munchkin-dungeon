extends GutTest

## Tests for StatCalculator — pure static math, no side effects.


# -- compute_hero_stats --

func test_compute_hero_stats_base_stats_level_1() -> void:
	var data := TestFactory.make_unit_data()
	var stats := StatCalculator.compute_hero_stats(data)

	# Level 1, base 5 all, no race mods, no equipment
	# STR = 5 + floor(1 * 0.5) + 0 = 5
	assert_eq(stats.damage, 5 * 2, "damage = STR * 2")
	assert_eq(stats.magic_damage, 5 * 2, "magic_damage = INT * 2")
	assert_eq(stats.max_hp, 50 + 5 * 8, "max_hp = BASE_HP + VIT * 8")
	assert_eq(stats.defense, 5, "defense = VIT")
	assert_eq(stats.initiative, 5 * 3, "initiative = AGI * 3")
	assert_almost_eq(stats.dodge_chance, 5 * 0.02, 0.001, "dodge_chance = AGI * 0.02")
	assert_almost_eq(stats.crit_chance, 5 * 0.03, 0.001, "crit_chance = LUCK * 0.03")
	assert_almost_eq(stats.crit_multiplier, 2.0 + 5 * 0.1, 0.001, "crit_multi = 2.0 + LUCK * 0.1")


func test_compute_hero_stats_level_scaling() -> void:
	var data := TestFactory.make_unit_data({"level": 10})
	var stats := StatCalculator.compute_hero_stats(data)

	# STR = 5 + floor(10 * 0.5) + 0 = 10
	assert_eq(stats.damage, 10 * 2, "level 10: STR should scale")
	assert_eq(stats.max_hp, 50 + 10 * 8, "level 10: VIT should scale")


func test_compute_hero_stats_race_modifiers() -> void:
	var race := TestFactory.make_race({"str_mod": 3, "agi_mod": -1, "vit_mod": 2})
	var data := TestFactory.make_unit_data({"race": race})
	var stats := StatCalculator.compute_hero_stats(data)

	# STR = 5 + 0 + 3 = 8
	assert_eq(stats.damage, 8 * 2, "race str_mod adds to damage")

	# AGI = 5 + 0 - 1 = 4
	assert_eq(stats.initiative, 4 * 3, "race agi_mod subtracts from initiative")

	# VIT = 5 + 0 + 2 = 7
	assert_eq(stats.max_hp, 50 + 7 * 8, "race vit_mod adds to max_hp")


func test_compute_hero_stats_equipment_bonuses() -> void:
	var weapon := TestFactory.make_equipment({"bonus_damage": 5, "bonus_str": 2})
	var armor := TestFactory.make_equipment({"bonus_defense": 3, "bonus_hp": 10, "bonus_vit": 1})
	var data := TestFactory.make_unit_data({"equipment": [weapon, armor]})
	var stats := StatCalculator.compute_hero_stats(data)

	# STR = 5 + 0 + 0 + 2 = 7, damage = 7*2 + 5 = 19
	assert_eq(stats.damage, 7 * 2 + 5, "equipment adds bonus_damage and bonus_str")

	# VIT = 5 + 0 + 0 + 1 = 6, defense = 6 + 3 = 9
	assert_eq(stats.defense, 6 + 3, "equipment adds bonus_defense and bonus_vit")

	# max_hp = 50 + 6*8 + 10 = 108
	assert_eq(stats.max_hp, 50 + 6 * 8 + 10, "equipment adds bonus_hp")


func test_compute_hero_stats_dodge_cap() -> void:
	var race := TestFactory.make_race({"agi_mod": 50})
	var data := TestFactory.make_unit_data({"race": race})
	var stats := StatCalculator.compute_hero_stats(data)

	assert_almost_eq(stats.dodge_chance, 0.40, 0.001, "dodge capped at 40%")


func test_compute_hero_stats_crit_cap() -> void:
	var race := TestFactory.make_race({"luck_mod": 50})
	var data := TestFactory.make_unit_data({"race": race})
	var stats := StatCalculator.compute_hero_stats(data)

	assert_almost_eq(stats.crit_chance, 0.30, 0.001, "crit chance capped at 30%")
	assert_almost_eq(stats.crit_multiplier, 3.0, 0.001, "crit multiplier capped at 3.0")


func test_compute_hero_stats_foresight_trait() -> void:
	var race := TestFactory.make_race({"trait_id": "foresight"})
	var data := TestFactory.make_unit_data({"race": race})
	var stats := StatCalculator.compute_hero_stats(data)

	# Base dodge = 5 * 0.02 = 0.10, foresight adds 0.10 = 0.20
	assert_almost_eq(stats.dodge_chance, 0.20, 0.001, "foresight adds 10% dodge")
	assert_eq(stats.trait_id, "foresight")


func test_compute_hero_stats_foresight_respects_dodge_cap() -> void:
	var race := TestFactory.make_race({"trait_id": "foresight", "agi_mod": 30})
	var data := TestFactory.make_unit_data({"race": race})
	var stats := StatCalculator.compute_hero_stats(data)

	assert_almost_eq(stats.dodge_chance, 0.40, 0.001, "foresight + high AGI still capped at 40%")


func test_compute_hero_stats_sturdy_trait() -> void:
	var race := TestFactory.make_race({"trait_id": "sturdy"})
	var data := TestFactory.make_unit_data({"race": race})
	var stats := StatCalculator.compute_hero_stats(data)

	# VIT = 5, defense = 5 + 3 (sturdy bonus) = 8
	assert_eq(stats.defense, 5 + 3, "sturdy adds +3 defense")
	assert_eq(stats.trait_id, "sturdy")


# -- resolve_attack --

func test_resolve_attack_no_dodge_no_crit() -> void:
	var result := StatCalculator.resolve_attack(20, 0.0, 2.0, "", 0, 0.0, "", 1.0)

	assert_false(result.dodged)
	assert_false(result.crit)
	assert_eq(result.final_damage, 20, "no defense, no crit: raw damage")


func test_resolve_attack_guaranteed_dodge() -> void:
	var result := StatCalculator.resolve_attack(20, 0.0, 2.0, "", 0, 1.0, "", 1.0)

	assert_true(result.dodged)
	assert_eq(result.final_damage, 0)


func test_resolve_attack_guaranteed_crit() -> void:
	var result := StatCalculator.resolve_attack(20, 1.0, 2.0, "", 0, 0.0, "", 1.0)

	assert_false(result.dodged)
	assert_true(result.crit)
	assert_eq(result.final_damage, 40, "2x crit multiplier")


func test_resolve_attack_defense_reduction() -> void:
	# defense = 10 → reduction = min(0.80, 10 * 0.02) = 0.20
	# raw = 20, reduced = 20 * 0.80 = 16
	var result := StatCalculator.resolve_attack(20, 0.0, 2.0, "", 10, 0.0, "", 1.0)

	assert_eq(result.final_damage, 16)


func test_resolve_attack_defense_cap() -> void:
	# defense = 100 → reduction = min(0.80, 100 * 0.02) = 0.80 (capped)
	# raw = 100, reduced = 100 * (1.0 - 0.80)
	# Note: floorf(100 * 0.1999...) = 19 due to float precision of 1.0 - 0.80
	var result := StatCalculator.resolve_attack(100, 0.0, 2.0, "", 100, 0.0, "", 1.0)

	assert_eq(result.final_damage, 19)


func test_resolve_attack_minimum_damage() -> void:
	# defense = 40 → reduction = min(0.80, 0.80) = 0.80
	# raw = 1 * 1.0 = 1, reduced = 1 * 0.20 = 0.2 → floor = 0 → clamped to 1
	var result := StatCalculator.resolve_attack(1, 0.0, 2.0, "", 40, 0.0, "", 1.0)

	assert_eq(result.final_damage, 1, "minimum damage is always 1")


func test_resolve_attack_ability_power_multiplier() -> void:
	# raw = 20 * 1.5 = 30
	var result := StatCalculator.resolve_attack(20, 0.0, 2.0, "", 0, 0.0, "", 1.5)

	assert_eq(result.final_damage, 30)


func test_resolve_attack_thick_skull_reduces_crit_bonus() -> void:
	# raw = 20 * 1.0 = 20, crit = 20 * 2.0 = 40
	# bonus_crit_damage = 40 - 20 = 20
	# thick_skull: raw -= 20 * 0.5 = 10, so raw = 30
	# no defense: final = 30
	var result := StatCalculator.resolve_attack(20, 1.0, 2.0, "", 0, 0.0, "thick_skull", 1.0)

	assert_true(result.crit)
	assert_eq(result.final_damage, 30, "thick_skull halves crit bonus damage")


func test_resolve_attack_crit_with_defense() -> void:
	# raw = 20 * 1.0 = 20, crit at 3x = 60
	# defense = 5 → reduction = 0.10, reduced = 60 * 0.90 = 54
	var result := StatCalculator.resolve_attack(20, 1.0, 3.0, "", 5, 0.0, "", 1.0)

	assert_true(result.crit)
	assert_eq(result.final_damage, 54)
