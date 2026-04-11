class_name StatCalculator
extends RefCounted

## Centralized stat formulas from the design doc.
## All combat math lives here for easy tuning.
##
## Resource properties are accessed via get() because the typed Resource
## classes (RaceData, ClassData, etc.) aren't resolvable at compile time
## when used as base Resource type.

# -- Balance Constants --
const BASE_HP: int = 50
const VIT_HP_MULTIPLIER: int = 8
const STR_DAMAGE_MULTIPLIER: int = 2
const INT_DAMAGE_MULTIPLIER: int = 2
const AGI_INITIATIVE_MULTIPLIER: int = 3
const AGI_DODGE_PER_POINT: float = 0.02
const DODGE_CAP: float = 0.40
const LUCK_CRIT_PER_POINT: float = 0.03
const CRIT_CHANCE_CAP: float = 0.30
const CRIT_MULTI_BASE: float = 2.0
const CRIT_MULTI_PER_LUCK: float = 0.1
const CRIT_MULTI_CAP: float = 3.0
const DEFENSE_REDUCTION_PER_POINT: float = 0.02
const DEFENSE_REDUCTION_CAP: float = 0.80
const MIN_DAMAGE: int = 1
const THICK_SKULL_CRIT_REDUCTION: float = 0.5
const FORESIGHT_DODGE_BONUS: float = 0.10
const STURDY_DEFENSE_BONUS: int = 3


static func compute_hero_stats(unit_data: Resource) -> Dictionary:
	var race: Resource = unit_data.get("race")
	var unit_class: Resource = unit_data.get("unit_class")
	var level: int = unit_data.get("level")
	var equipment: Array = unit_data.get("equipment")

	# Primary stats: class base + level growth + race mods + equipment
	var primary_str: int = _gi(unit_class, "base_str") + floori(level * _gf(unit_class, "str_per_level")) + _gi(race, "str_mod")
	var primary_agi: int = _gi(unit_class, "base_agi") + floori(level * _gf(unit_class, "agi_per_level")) + _gi(race, "agi_mod")
	var primary_vit: int = _gi(unit_class, "base_vit") + floori(level * _gf(unit_class, "vit_per_level")) + _gi(race, "vit_mod")
	var primary_int: int = _gi(unit_class, "base_int") + floori(level * _gf(unit_class, "int_per_level")) + _gi(race, "int_mod")
	var primary_luck: int = _gi(unit_class, "base_luck") + floori(level * _gf(unit_class, "luck_per_level")) + _gi(race, "luck_mod")

	# Equipment bonuses to primary stats
	var equip_str: int = 0
	var equip_agi: int = 0
	var equip_vit: int = 0
	var equip_int: int = 0
	var equip_luck: int = 0
	var weapon_bonus: int = 0
	var armor_bonus: int = 0
	var hp_bonus: int = 0
	var init_bonus: int = 0

	for eq: Resource in equipment:
		equip_str += _gi(eq, "bonus_str")
		equip_agi += _gi(eq, "bonus_agi")
		equip_vit += _gi(eq, "bonus_vit")
		equip_int += _gi(eq, "bonus_int")
		equip_luck += _gi(eq, "bonus_luck")
		weapon_bonus += _gi(eq, "bonus_damage")
		armor_bonus += _gi(eq, "bonus_defense")
		hp_bonus += _gi(eq, "bonus_hp")
		init_bonus += _gi(eq, "bonus_initiative")

	var final_str: int = primary_str + equip_str
	var final_agi: int = primary_agi + equip_agi
	var final_vit: int = primary_vit + equip_vit
	var final_int: int = primary_int + equip_int
	var final_luck: int = primary_luck + equip_luck

	# Derived stats
	var max_hp: int = BASE_HP + (final_vit * VIT_HP_MULTIPLIER) + hp_bonus
	var damage: int = final_str * STR_DAMAGE_MULTIPLIER + weapon_bonus
	var magic_damage: int = final_int * INT_DAMAGE_MULTIPLIER + weapon_bonus
	var defense: int = final_vit + armor_bonus
	var initiative: int = final_agi * AGI_INITIATIVE_MULTIPLIER + init_bonus
	var dodge_chance: float = minf(DODGE_CAP, final_agi * AGI_DODGE_PER_POINT)
	var crit_chance: float = minf(CRIT_CHANCE_CAP, final_luck * LUCK_CRIT_PER_POINT)
	var crit_multiplier: float = minf(CRIT_MULTI_CAP, CRIT_MULTI_BASE + final_luck * CRIT_MULTI_PER_LUCK)

	# Racial trait adjustments
	var trait_id: String = _gs(race, "trait_id")

	if trait_id == "foresight":
		dodge_chance = minf(DODGE_CAP, dodge_chance + FORESIGHT_DODGE_BONUS)

	if trait_id == "sturdy":
		defense += STURDY_DEFENSE_BONUS

	return {
		"max_hp": max_hp,
		"damage": damage,
		"magic_damage": magic_damage,
		"defense": defense,
		"initiative": initiative,
		"dodge_chance": dodge_chance,
		"crit_chance": crit_chance,
		"crit_multiplier": crit_multiplier,
		"trait_id": trait_id,
	}


static func resolve_attack(
	attacker_damage: int,
	attacker_crit_chance: float,
	attacker_crit_multiplier: float,
	attacker_trait: String,
	defender_defense: int,
	defender_dodge_chance: float,
	defender_trait: String,
	ability_power: float,
) -> Dictionary:
	## Runs the 4-step damage pipeline. Returns {dodged, crit, final_damage}.

	# Step 1: Dodge check
	if randf() < defender_dodge_chance:
		return {"dodged": true, "crit": false, "final_damage": 0}

	# Step 2: Raw damage
	var raw: float = attacker_damage * ability_power

	# Step 3: Crit check
	var is_crit: bool = randf() < attacker_crit_chance

	if is_crit:
		raw *= attacker_crit_multiplier

		# Thick skull: reduced crit bonus damage
		if defender_trait == "thick_skull":
			var bonus_crit_damage: float = raw - (attacker_damage * ability_power)
			raw -= bonus_crit_damage * THICK_SKULL_CRIT_REDUCTION

	# Step 4: Defense reduction
	var reduction: float = minf(DEFENSE_REDUCTION_CAP, defender_defense * DEFENSE_REDUCTION_PER_POINT)
	var reduced: float = raw * (1.0 - reduction)

	var final_damage: int = maxi(MIN_DAMAGE, floori(reduced))

	return {"dodged": false, "crit": is_crit, "final_damage": final_damage}


# -- Typed get helpers for Resource property access --

static func _gi(res: Resource, prop: String) -> int:
	return res.get(prop) as int


static func _gf(res: Resource, prop: String) -> float:
	return res.get(prop) as float


static func _gs(res: Resource, prop: String) -> String:
	return res.get(prop) as String
