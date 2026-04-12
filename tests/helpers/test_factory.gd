class_name TestFactory
extends RefCounted

## Factory for creating test Resources and BattleUnits in-memory.
## Avoids loading .tres files so tests stay independent of data files.


static func make_race(overrides: Dictionary = {}) -> RaceData:
	var r := RaceData.new()
	r.id = overrides.get("id", "test_race")
	r.display_name = overrides.get("display_name", "Test Race")
	r.str_mod = overrides.get("str_mod", 0)
	r.agi_mod = overrides.get("agi_mod", 0)
	r.vit_mod = overrides.get("vit_mod", 0)
	r.int_mod = overrides.get("int_mod", 0)
	r.luck_mod = overrides.get("luck_mod", 0)
	r.trait_id = overrides.get("trait_id", "")
	r.trait_description = overrides.get("trait_description", "")
	return r


static func make_class(overrides: Dictionary = {}) -> ClassData:
	var c := ClassData.new()
	c.id = overrides.get("id", "test_class")
	c.display_name = overrides.get("display_name", "Test Class")
	c.base_str = overrides.get("base_str", 5)
	c.base_agi = overrides.get("base_agi", 5)
	c.base_vit = overrides.get("base_vit", 5)
	c.base_int = overrides.get("base_int", 5)
	c.base_luck = overrides.get("base_luck", 5)
	c.str_per_level = overrides.get("str_per_level", 0.5)
	c.agi_per_level = overrides.get("agi_per_level", 0.5)
	c.vit_per_level = overrides.get("vit_per_level", 0.5)
	c.int_per_level = overrides.get("int_per_level", 0.5)
	c.luck_per_level = overrides.get("luck_per_level", 0.5)
	c.abilities.assign(overrides.get("abilities", []))
	c.preferred_row = overrides.get("preferred_row", "front")
	c.color = overrides.get("color", Color.WHITE)
	c.sprite_path = overrides.get("sprite_path", "")
	return c


static func make_equipment(overrides: Dictionary = {}) -> EquipmentData:
	var e := EquipmentData.new()
	e.id = overrides.get("id", "test_equip")
	e.display_name = overrides.get("display_name", "Test Equipment")
	e.slot = overrides.get("slot", "weapon")
	e.rarity = overrides.get("rarity", "common")
	e.required_class = overrides.get("required_class", "")
	e.bonus_str = overrides.get("bonus_str", 0)
	e.bonus_agi = overrides.get("bonus_agi", 0)
	e.bonus_vit = overrides.get("bonus_vit", 0)
	e.bonus_int = overrides.get("bonus_int", 0)
	e.bonus_luck = overrides.get("bonus_luck", 0)
	e.bonus_damage = overrides.get("bonus_damage", 0)
	e.bonus_defense = overrides.get("bonus_defense", 0)
	e.bonus_hp = overrides.get("bonus_hp", 0)
	e.bonus_initiative = overrides.get("bonus_initiative", 0)
	return e


static func make_ability(overrides: Dictionary = {}) -> AbilityData:
	var a := AbilityData.new()
	a.id = overrides.get("id", "test_ability")
	a.display_name = overrides.get("display_name", "Test Ability")
	a.description = overrides.get("description", "")
	a.cooldown = overrides.get("cooldown", 0)
	a.target_type = overrides.get("target_type", "enemy")
	a.reach = overrides.get("reach", "melee")
	a.effect_type = overrides.get("effect_type", "damage")
	a.damage_stat = overrides.get("damage_stat", "str")
	a.power = overrides.get("power", 1.0)
	a.heal_amount = overrides.get("heal_amount", 0)
	a.secondary_effect = overrides.get("secondary_effect", "")
	a.secondary_chance = overrides.get("secondary_chance", 0.0)
	a.secondary_duration = overrides.get("secondary_duration", 0)
	a.secondary_value = overrides.get("secondary_value", 0)
	a.ai_priority = overrides.get("ai_priority", 0)
	a.ai_condition = overrides.get("ai_condition", null)
	a.ai_target_strategy = overrides.get("ai_target_strategy", "weighted_random")
	return a


static func make_condition(scope: String = "always", property: String = "", compare: String = "", value: float = 0.0) -> AIConditionData:
	var c := AIConditionData.new()
	c.scope = scope
	c.property = property
	c.compare = compare
	c.value = value
	return c


static func make_unit_data(overrides: Dictionary = {}) -> UnitData:
	var u := UnitData.new()
	u.id = overrides.get("id", "test_hero")
	u.display_name = overrides.get("display_name", "Test Hero")
	u.race = overrides.get("race", make_race())
	u.unit_class = overrides.get("unit_class", make_class())
	u.level = overrides.get("level", 1)
	u.equipment.assign(overrides.get("equipment", []))
	return u


static func make_monster_data(overrides: Dictionary = {}) -> MonsterData:
	var m := MonsterData.new()
	m.id = overrides.get("id", "test_monster")
	m.display_name = overrides.get("display_name", "Test Monster")
	m.tier = overrides.get("tier", 1)
	m.max_hp = overrides.get("max_hp", 50)
	m.damage = overrides.get("damage", 10)
	m.defense = overrides.get("defense", 3)
	m.initiative = overrides.get("initiative", 10)
	m.dodge_chance = overrides.get("dodge_chance", 0.0)
	m.crit_chance = overrides.get("crit_chance", 0.0)
	m.crit_multiplier = overrides.get("crit_multiplier", 2.0)
	m.abilities.assign(overrides.get("abilities", [make_basic_attack()]))
	m.preferred_row = overrides.get("preferred_row", "front")
	m.is_boss = overrides.get("is_boss", false)
	m.phase2_hp_percent = overrides.get("phase2_hp_percent", 0.5)
	m.phase2_abilities.assign(overrides.get("phase2_abilities", []))
	m.phase2_stat_multiplier = overrides.get("phase2_stat_multiplier", 1.0)
	m.xp_reward = overrides.get("xp_reward", 10)
	m.color = overrides.get("color", Color.RED)
	m.sprite_path = overrides.get("sprite_path", "")
	return m


static func make_basic_attack() -> AbilityData:
	return make_ability({
		"id": "basic_attack",
		"display_name": "Basic Attack",
		"target_type": "enemy",
		"reach": "melee",
		"effect_type": "damage",
		"power": 1.0,
	})


static func make_hero_unit(overrides: Dictionary = {}) -> BattleUnit:
	var data := overrides.get("unit_data", make_unit_data(overrides.get("unit_overrides", {}))) as Resource
	var side: String = overrides.get("side", "hero")
	var row: String = overrides.get("row", "front")
	var slot: int = overrides.get("slot", 0)
	return BattleUnit.from_hero(data, side, row, slot)


static func make_monster_unit(overrides: Dictionary = {}) -> BattleUnit:
	var data := overrides.get("monster_data", make_monster_data(overrides.get("monster_overrides", {}))) as Resource
	var side: String = overrides.get("side", "enemy")
	var row: String = overrides.get("row", "front")
	var slot: int = overrides.get("slot", 0)
	return BattleUnit.from_monster(data, side, row, slot)
