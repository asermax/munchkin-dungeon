@tool
extends SceneTree

## Generates all .tres data files for the battle MVP.
## Run with: godot --headless --script res://tools/setup_data.gd
##
## In --script mode, class_name types from other files aren't available.
## We load each resource script explicitly and instantiate from it.

var AbilityScript: GDScript
var RaceScript: GDScript
var ClassScript: GDScript
var EquipmentScript: GDScript
var UnitScript: GDScript
var MonsterScript: GDScript
var EncounterScript: GDScript


func _init() -> void:
	AbilityScript = load("res://resources/ability_data.gd")
	RaceScript = load("res://resources/race_data.gd")
	ClassScript = load("res://resources/class_data.gd")
	EquipmentScript = load("res://resources/equipment_data.gd")
	UnitScript = load("res://resources/unit_data.gd")
	MonsterScript = load("res://resources/monster_data.gd")
	EncounterScript = load("res://resources/encounter_data.gd")

	_create_abilities()
	_create_races()
	_create_equipment()
	_create_classes()
	_create_monsters()
	_create_encounters()
	_create_test_heroes()

	print("Data setup complete.")
	quit()


# ---------- Abilities ----------

func _create_abilities() -> void:
	_ensure_dir("res://data/abilities/warrior")
	_ensure_dir("res://data/abilities/mage")
	_ensure_dir("res://data/abilities/rogue")
	_ensure_dir("res://data/abilities/cleric")
	_ensure_dir("res://data/abilities/monster")

	# Shared basic attack
	_save(_ability("basic_attack", "Basic Attack", "A simple attack.", {
		"cooldown": 0, "target_type": "enemy", "reach": "melee",
		"effect_type": "damage", "damage_stat": "str", "power": 1.0,
		"ai_priority": 0, "ai_condition": "always",
	}), "res://data/abilities/basic_attack.tres")

	# ---- Warrior ----

	_save(_ability("taunt", "Taunt", "Forces enemies to target the warrior.", {
		"cooldown": 3, "target_type": "self", "reach": "melee",
		"effect_type": "taunt", "power": 0.0,
		"secondary_effect": "taunt", "secondary_duration": 2,
		"ai_priority": 60, "ai_condition": "ally_below_40",
	}), "res://data/abilities/warrior/taunt.tres")

	_save(_ability("shield_wall", "Shield Wall", "Raises defense significantly for 2 rounds.", {
		"cooldown": 3, "target_type": "self", "reach": "melee",
		"effect_type": "buff",
		"secondary_effect": "defense_up", "secondary_chance": 1.0,
		"secondary_duration": 2, "secondary_value": 5,
		"ai_priority": 50, "ai_condition": "self_below_50",
	}), "res://data/abilities/warrior/shield_wall.tres")

	_save(_ability("revenge", "Revenge", "Powerful counter-strike dealing 1.8x damage.", {
		"cooldown": 2, "target_type": "enemy", "reach": "melee",
		"effect_type": "damage", "damage_stat": "str", "power": 1.8,
		"ai_priority": 40, "ai_condition": "self_below_50",
	}), "res://data/abilities/warrior/revenge.tres")

	_save(_ability("charge", "Charge", "Charges an enemy for 1.4x damage.", {
		"cooldown": 2, "target_type": "enemy", "reach": "melee",
		"effect_type": "damage", "damage_stat": "str", "power": 1.4,
		"ai_priority": 30, "ai_condition": "always",
	}), "res://data/abilities/warrior/charge.tres")

	_save(_ability("cleave", "Cleave", "Strikes all enemies in the front row.", {
		"cooldown": 2, "target_type": "all_enemies", "reach": "melee",
		"effect_type": "damage", "damage_stat": "str", "power": 0.8,
		"ai_priority": 25, "ai_condition": "enemies_gte_3",
	}), "res://data/abilities/warrior/cleave.tres")

	_save(_ability("power_strike", "Power Strike", "A focused blow dealing 1.3x damage.", {
		"cooldown": 1, "target_type": "enemy", "reach": "melee",
		"effect_type": "damage", "damage_stat": "str", "power": 1.3,
		"ai_priority": 10, "ai_condition": "always",
	}), "res://data/abilities/warrior/power_strike.tres")

	# ---- Mage ----

	_save(_ability("chain_lightning", "Chain Lightning", "Shocks all enemies with lightning.", {
		"cooldown": 3, "target_type": "all_enemies", "reach": "ranged",
		"effect_type": "damage", "damage_stat": "int", "power": 0.7,
		"ai_priority": 60, "ai_condition": "enemies_gte_3",
	}), "res://data/abilities/mage/chain_lightning.tres")

	_save(_ability("frost", "Frost", "Deals damage and may stun an enemy.", {
		"cooldown": 2, "target_type": "enemy", "reach": "ranged",
		"effect_type": "damage", "damage_stat": "int", "power": 1.2,
		"secondary_effect": "stun", "secondary_chance": 0.4, "secondary_duration": 1,
		"ai_priority": 50, "ai_condition": "always",
	}), "res://data/abilities/mage/frost.tres")

	_save(_ability("fireball", "Fireball", "Hurls a ball of fire for 1.5x magic damage.", {
		"cooldown": 2, "target_type": "enemy", "reach": "ranged",
		"effect_type": "damage", "damage_stat": "int", "power": 1.5,
		"ai_priority": 40, "ai_condition": "always",
	}), "res://data/abilities/mage/fireball.tres")

	_save(_ability("arcane_shield", "Arcane Shield", "Creates a magical barrier.", {
		"cooldown": 3, "target_type": "self", "reach": "ranged",
		"effect_type": "buff",
		"secondary_effect": "defense_up", "secondary_chance": 1.0,
		"secondary_duration": 2, "secondary_value": 4,
		"ai_priority": 35, "ai_condition": "self_below_50",
	}), "res://data/abilities/mage/arcane_shield.tres")

	_save(_ability("mana_drain", "Mana Drain", "Drains life from an enemy.", {
		"cooldown": 2, "target_type": "enemy", "reach": "ranged",
		"effect_type": "damage", "damage_stat": "int", "power": 1.0,
		"secondary_effect": "life_drain", "secondary_chance": 1.0, "secondary_value": 8,
		"ai_priority": 25, "ai_condition": "self_below_50",
	}), "res://data/abilities/mage/mana_drain.tres")

	_save(_ability("arcane_bolt", "Arcane Bolt", "A quick bolt of arcane energy.", {
		"cooldown": 0, "target_type": "enemy", "reach": "ranged",
		"effect_type": "damage", "damage_stat": "int", "power": 1.1,
		"ai_priority": 10, "ai_condition": "always",
	}), "res://data/abilities/mage/arcane_bolt.tres")

	# ---- Rogue ----

	_save(_ability("evasion", "Evasion", "Greatly boosts dodge for 2 rounds.", {
		"cooldown": 3, "target_type": "self", "reach": "melee",
		"effect_type": "buff",
		"secondary_effect": "dodge_up", "secondary_chance": 1.0,
		"secondary_duration": 2, "secondary_value": 20,
		"ai_priority": 60, "ai_condition": "self_below_30",
	}), "res://data/abilities/rogue/evasion.tres")

	_save(_ability("smoke_bomb", "Smoke Bomb", "Reduces all enemies' accuracy.", {
		"cooldown": 3, "target_type": "all_enemies", "reach": "ranged",
		"effect_type": "debuff",
		"secondary_effect": "accuracy_down", "secondary_chance": 1.0,
		"secondary_duration": 2, "secondary_value": 15,
		"ai_priority": 50, "ai_condition": "enemies_gte_3",
	}), "res://data/abilities/rogue/smoke_bomb.tres")

	_save(_ability("execute", "Execute", "Finishes off a weakened enemy for 2.0x damage.", {
		"cooldown": 2, "target_type": "enemy", "reach": "melee",
		"effect_type": "damage", "damage_stat": "str", "power": 2.0,
		"ai_priority": 45, "ai_condition": "enemy_below_20",
	}), "res://data/abilities/rogue/execute.tres")

	_save(_ability("backstab", "Backstab", "Strikes from behind for 1.6x damage.", {
		"cooldown": 1, "target_type": "enemy", "reach": "melee",
		"effect_type": "damage", "damage_stat": "str", "power": 1.6,
		"ai_priority": 30, "ai_condition": "always",
	}), "res://data/abilities/rogue/backstab.tres")

	_save(_ability("poison_blade", "Poison Blade", "Poisons the target for damage over time.", {
		"cooldown": 2, "target_type": "enemy", "reach": "melee",
		"effect_type": "damage", "damage_stat": "str", "power": 1.0,
		"secondary_effect": "poison", "secondary_chance": 0.8,
		"secondary_duration": 3, "secondary_value": 5,
		"ai_priority": 20, "ai_condition": "always",
	}), "res://data/abilities/rogue/poison_blade.tres")

	_save(_ability("twin_strike", "Twin Strike", "Two quick strikes at 0.7x each.", {
		"cooldown": 1, "target_type": "enemy", "reach": "melee",
		"effect_type": "damage", "damage_stat": "str", "power": 1.4,
		"ai_priority": 10, "ai_condition": "always",
	}), "res://data/abilities/rogue/twin_strike.tres")

	# ---- Cleric ----

	_save(_ability("resurrect", "Resurrect", "Revives a fallen ally at 10% HP. Once per battle.", {
		"cooldown": 99, "target_type": "ally", "reach": "ranged",
		"effect_type": "resurrect",
		"ai_priority": 70, "ai_condition": "ally_dead",
	}), "res://data/abilities/cleric/resurrect.tres")

	_save(_ability("heal", "Heal", "Restores a significant amount of HP to an ally.", {
		"cooldown": 2, "target_type": "ally", "reach": "ranged",
		"effect_type": "heal", "heal_amount": 30,
		"ai_priority": 60, "ai_condition": "ally_below_40",
	}), "res://data/abilities/cleric/heal.tres")

	_save(_ability("purify", "Purify", "Removes negative effects from an ally.", {
		"cooldown": 2, "target_type": "ally", "reach": "ranged",
		"effect_type": "buff",
		"secondary_effect": "cleanse", "secondary_chance": 1.0,
		"ai_priority": 50, "ai_condition": "ally_cursed",
	}), "res://data/abilities/cleric/purify.tres")

	_save(_ability("holy_shield", "Holy Shield", "Grants an ally a defensive buff.", {
		"cooldown": 3, "target_type": "ally", "reach": "ranged",
		"effect_type": "buff",
		"secondary_effect": "defense_up", "secondary_chance": 1.0,
		"secondary_duration": 2, "secondary_value": 4,
		"ai_priority": 40, "ai_condition": "always",
	}), "res://data/abilities/cleric/holy_shield.tres")

	_save(_ability("bless", "Bless", "Boosts an ally's damage for 2 rounds.", {
		"cooldown": 3, "target_type": "ally", "reach": "ranged",
		"effect_type": "buff",
		"secondary_effect": "damage_up", "secondary_chance": 1.0,
		"secondary_duration": 2, "secondary_value": 4,
		"ai_priority": 30, "ai_condition": "always",
	}), "res://data/abilities/cleric/bless.tres")

	_save(_ability("smite", "Smite", "Holy damage against a single enemy.", {
		"cooldown": 1, "target_type": "enemy", "reach": "ranged",
		"effect_type": "damage", "damage_stat": "int", "power": 1.3,
		"ai_priority": 10, "ai_condition": "always",
	}), "res://data/abilities/cleric/smite.tres")

	# ---- Monster abilities ----

	_save(_ability("shield_bash", "Shield Bash", "Bashes with a shield, may stun.", {
		"cooldown": 2, "target_type": "enemy", "reach": "melee",
		"effect_type": "damage", "damage_stat": "str", "power": 1.2,
		"secondary_effect": "stun", "secondary_chance": 0.5, "secondary_duration": 1,
		"ai_priority": 20, "ai_condition": "always",
	}), "res://data/abilities/monster/shield_bash.tres")

	_save(_ability("smash", "Smash", "Hits all front-row enemies.", {
		"cooldown": 3, "target_type": "all_enemies", "reach": "melee",
		"effect_type": "damage", "damage_stat": "str", "power": 1.3,
		"ai_priority": 20, "ai_condition": "always",
	}), "res://data/abilities/monster/smash.tres")

	_save(_ability("heal_ally", "Heal Ally", "Heals a wounded ally.", {
		"cooldown": 2, "target_type": "ally", "reach": "ranged",
		"effect_type": "heal", "heal_amount": 30,
		"ai_priority": 30, "ai_condition": "ally_below_40",
	}), "res://data/abilities/monster/heal_ally.tres")

	_save(_ability("iron_hide", "Iron Hide", "Greatly increases own defense.", {
		"cooldown": 3, "target_type": "self", "reach": "melee",
		"effect_type": "buff",
		"secondary_effect": "defense_up", "secondary_chance": 1.0,
		"secondary_duration": 2, "secondary_value": 6,
		"ai_priority": 20, "ai_condition": "always",
	}), "res://data/abilities/monster/iron_hide.tres")

	_save(_ability("gore", "Gore", "Gores the target, causing bleed.", {
		"cooldown": 2, "target_type": "enemy", "reach": "melee",
		"effect_type": "damage", "damage_stat": "str", "power": 1.5,
		"secondary_effect": "bleed", "secondary_chance": 0.7,
		"secondary_duration": 3, "secondary_value": 4,
		"ai_priority": 20, "ai_condition": "always",
	}), "res://data/abilities/monster/gore.tres")

	_save(_ability("life_drain", "Life Drain", "Drains life from an enemy.", {
		"cooldown": 2, "target_type": "enemy", "reach": "ranged",
		"effect_type": "damage", "damage_stat": "str", "power": 1.2,
		"secondary_effect": "life_drain", "secondary_chance": 1.0, "secondary_value": 10,
		"ai_priority": 25, "ai_condition": "always",
	}), "res://data/abilities/monster/life_drain.tres")

	_save(_ability("earthquake", "Earthquake", "Shakes the ground, hitting all enemies.", {
		"cooldown": 3, "target_type": "all_enemies", "reach": "ranged",
		"effect_type": "damage", "damage_stat": "str", "power": 0.8,
		"ai_priority": 30, "ai_condition": "enemies_gte_3",
	}), "res://data/abilities/monster/earthquake.tres")

	_save(_ability("flame_snort", "Flame Snort", "Blasts flames at the front row.", {
		"cooldown": 2, "target_type": "all_enemies", "reach": "melee",
		"effect_type": "damage", "damage_stat": "str", "power": 1.3,
		"secondary_effect": "bleed", "secondary_chance": 0.5,
		"secondary_duration": 2, "secondary_value": 5,
		"ai_priority": 25, "ai_condition": "always",
	}), "res://data/abilities/monster/flame_snort.tres")

	_save(_ability("lava_spit", "Lava Spit", "Spits molten lava at a single target.", {
		"cooldown": 2, "target_type": "enemy", "reach": "ranged",
		"effect_type": "damage", "damage_stat": "str", "power": 1.5,
		"secondary_effect": "bleed", "secondary_chance": 0.8,
		"secondary_duration": 3, "secondary_value": 6,
		"ai_priority": 35, "ai_condition": "always",
	}), "res://data/abilities/monster/lava_spit.tres")

	print("  Created abilities.")


# ---------- Races ----------

func _create_races() -> void:
	_ensure_dir("res://data/races")

	_save(_race("human", "Human", {
		"trait_id": "adaptive",
		"trait_description": "Balanced stats, no class restrictions.",
	}), "res://data/races/human.tres")

	_save(_race("orc", "Orc", {
		"str_mod": 3, "vit_mod": 2, "int_mod": -3,
		"restricted_classes": ["mage"] as Array[String],
		"trait_id": "thick_skull",
		"trait_description": "Takes 50% less critical hit damage.",
	}), "res://data/races/orc.tres")

	_save(_race("elf", "Elf", {
		"agi_mod": 3, "vit_mod": -2, "int_mod": 3, "luck_mod": -1,
		"restricted_classes": ["warrior"] as Array[String],
		"trait_id": "foresight",
		"trait_description": "+10% dodge chance.",
	}), "res://data/races/elf.tres")

	_save(_race("dwarf", "Dwarf", {
		"str_mod": 1, "agi_mod": -2, "vit_mod": 3, "luck_mod": 1,
		"restricted_classes": ["rogue"] as Array[String],
		"trait_id": "sturdy",
		"trait_description": "+3 flat defense.",
	}), "res://data/races/dwarf.tres")

	print("  Created races.")


# ---------- Equipment ----------

func _create_equipment() -> void:
	_ensure_dir("res://data/equipment/weapons")
	_ensure_dir("res://data/equipment/armor")
	_ensure_dir("res://data/equipment/hats")
	_ensure_dir("res://data/equipment/boots")

	# Weapons
	_save(_equipment("iron_sword", "Iron Sword", "weapon", "common", "warrior", {
		"bonus_damage": 4, "bonus_str": 1,
	}), "res://data/equipment/weapons/iron_sword.tres")

	_save(_equipment("gnarled_staff", "Gnarled Staff", "weapon", "common", "mage", {
		"bonus_damage": 3, "bonus_int": 2,
	}), "res://data/equipment/weapons/gnarled_staff.tres")

	_save(_equipment("twin_daggers", "Twin Daggers", "weapon", "common", "rogue", {
		"bonus_damage": 3, "bonus_agi": 1, "bonus_str": 1,
	}), "res://data/equipment/weapons/twin_daggers.tres")

	_save(_equipment("holy_mace", "Holy Mace", "weapon", "common", "cleric", {
		"bonus_damage": 3, "bonus_int": 1, "bonus_vit": 1,
	}), "res://data/equipment/weapons/holy_mace.tres")

	# Armor
	_save(_equipment("plate_armor", "Plate Armor", "armor", "common", "warrior", {
		"bonus_defense": 4, "bonus_hp": 10,
	}), "res://data/equipment/armor/plate_armor.tres")

	_save(_equipment("mage_robe", "Mage Robe", "armor", "common", "mage", {
		"bonus_defense": 1, "bonus_int": 2, "bonus_hp": 5,
	}), "res://data/equipment/armor/mage_robe.tres")

	_save(_equipment("leather_armor", "Leather Armor", "armor", "common", "rogue", {
		"bonus_defense": 2, "bonus_agi": 1, "bonus_hp": 5,
	}), "res://data/equipment/armor/leather_armor.tres")

	_save(_equipment("chain_vestments", "Chain Vestments", "armor", "common", "cleric", {
		"bonus_defense": 3, "bonus_hp": 8,
	}), "res://data/equipment/armor/chain_vestments.tres")

	# Hats
	_save(_equipment("iron_helm", "Iron Helm", "hat", "common", "", {
		"bonus_defense": 1, "bonus_vit": 1,
	}), "res://data/equipment/hats/iron_helm.tres")

	_save(_equipment("wizard_hat", "Wizard Hat", "hat", "common", "", {
		"bonus_int": 2,
	}), "res://data/equipment/hats/wizard_hat.tres")

	_save(_equipment("lucky_bandana", "Lucky Bandana", "hat", "uncommon", "", {
		"bonus_luck": 2, "bonus_agi": 1,
	}), "res://data/equipment/hats/lucky_bandana.tres")

	# Boots
	_save(_equipment("iron_boots", "Iron Boots", "boots", "common", "", {
		"bonus_initiative": 2, "bonus_defense": 1,
	}), "res://data/equipment/boots/iron_boots.tres")

	_save(_equipment("swift_boots", "Swift Boots", "boots", "common", "", {
		"bonus_initiative": 4, "bonus_agi": 1,
	}), "res://data/equipment/boots/swift_boots.tres")

	_save(_equipment("sturdy_greaves", "Sturdy Greaves", "boots", "uncommon", "", {
		"bonus_initiative": 2, "bonus_vit": 1, "bonus_defense": 1,
	}), "res://data/equipment/boots/sturdy_greaves.tres")

	print("  Created equipment.")


# ---------- Classes ----------

func _create_classes() -> void:
	_ensure_dir("res://data/classes")

	var basic_attack: Resource = load("res://data/abilities/basic_attack.tres")

	# Warrior
	var w_abilities: Array[Resource] = [
		load("res://data/abilities/warrior/taunt.tres"),
		load("res://data/abilities/warrior/shield_wall.tres"),
		load("res://data/abilities/warrior/revenge.tres"),
		load("res://data/abilities/warrior/charge.tres"),
		load("res://data/abilities/warrior/cleave.tres"),
		load("res://data/abilities/warrior/power_strike.tres"),
		basic_attack,
	]

	_save(_class_data("warrior", "Warrior", {
		"base_str": 7, "base_agi": 4, "base_vit": 6, "base_int": 2, "base_luck": 4,
		"str_per_level": 1.5, "agi_per_level": 0.5, "vit_per_level": 1.0,
		"int_per_level": 0.0, "luck_per_level": 0.5,
		"abilities": w_abilities,
		"preferred_row": "front",
		"color": Color(0.3, 0.5, 0.9),
		"sprite_path": "res://assets/sprites/warrior.png",
	}), "res://data/classes/warrior.tres")

	# Mage
	var m_abilities: Array[Resource] = [
		load("res://data/abilities/mage/chain_lightning.tres"),
		load("res://data/abilities/mage/frost.tres"),
		load("res://data/abilities/mage/fireball.tres"),
		load("res://data/abilities/mage/arcane_shield.tres"),
		load("res://data/abilities/mage/mana_drain.tres"),
		load("res://data/abilities/mage/arcane_bolt.tres"),
		basic_attack,
	]

	_save(_class_data("mage", "Mage", {
		"base_str": 2, "base_agi": 4, "base_vit": 3, "base_int": 8, "base_luck": 4,
		"str_per_level": 0.0, "agi_per_level": 0.5, "vit_per_level": 0.5,
		"int_per_level": 1.5, "luck_per_level": 0.5,
		"abilities": m_abilities,
		"preferred_row": "back",
		"color": Color(0.6, 0.3, 0.8),
		"sprite_path": "res://assets/sprites/mage.png",
	}), "res://data/classes/mage.tres")

	# Rogue
	var r_abilities: Array[Resource] = [
		load("res://data/abilities/rogue/evasion.tres"),
		load("res://data/abilities/rogue/smoke_bomb.tres"),
		load("res://data/abilities/rogue/execute.tres"),
		load("res://data/abilities/rogue/backstab.tres"),
		load("res://data/abilities/rogue/poison_blade.tres"),
		load("res://data/abilities/rogue/twin_strike.tres"),
		basic_attack,
	]

	_save(_class_data("rogue", "Rogue", {
		"base_str": 4, "base_agi": 8, "base_vit": 3, "base_int": 2, "base_luck": 6,
		"str_per_level": 0.5, "agi_per_level": 1.5, "vit_per_level": 0.5,
		"int_per_level": 0.0, "luck_per_level": 1.0,
		"abilities": r_abilities,
		"preferred_row": "front",
		"color": Color(0.3, 0.7, 0.3),
		"sprite_path": "res://assets/sprites/rogue.png",
	}), "res://data/classes/rogue.tres")

	# Cleric
	var c_abilities: Array[Resource] = [
		load("res://data/abilities/cleric/resurrect.tres"),
		load("res://data/abilities/cleric/heal.tres"),
		load("res://data/abilities/cleric/purify.tres"),
		load("res://data/abilities/cleric/holy_shield.tres"),
		load("res://data/abilities/cleric/bless.tres"),
		load("res://data/abilities/cleric/smite.tres"),
		basic_attack,
	]

	_save(_class_data("cleric", "Cleric", {
		"base_str": 3, "base_agi": 3, "base_vit": 7, "base_int": 5, "base_luck": 4,
		"str_per_level": 0.5, "agi_per_level": 0.5, "vit_per_level": 1.0,
		"int_per_level": 1.0, "luck_per_level": 0.5,
		"abilities": c_abilities,
		"preferred_row": "back",
		"color": Color(0.9, 0.8, 0.2),
		"sprite_path": "res://assets/sprites/cleric.png",
	}), "res://data/classes/cleric.tres")

	print("  Created classes.")


# ---------- Monsters ----------

func _create_monsters() -> void:
	_ensure_dir("res://data/monsters/cave/tier1")
	_ensure_dir("res://data/monsters/cave/tier2")
	_ensure_dir("res://data/monsters/cave/boss")

	# -- Tier 1 --

	_save(_monster("hoglet", "Spiny Hoglet", 1, {
		"max_hp": 42, "damage": 10, "defense": 3, "initiative": 18,
		"dodge_chance": 0.05, "xp_reward": 8,
		"color": Color(0.9, 0.6, 0.6),
		"sprite_path": "res://assets/sprites/spiny_hoglet.png",
	}), "res://data/monsters/cave/tier1/hoglet.tres")

	_save(_monster("mud_hog", "Mudgehog", 1, {
		"max_hp": 65, "damage": 13, "defense": 5, "initiative": 12,
		"dodge_chance": 0.03, "xp_reward": 12,
		"color": Color(0.5, 0.35, 0.2),
		"sprite_path": "res://assets/sprites/mudgehog.png",
	}), "res://data/monsters/cave/tier1/mud_hog.tres")

	_save(_monster("winged_swine", "Winged Quillhog", 1, {
		"max_hp": 45, "damage": 14, "defense": 2, "initiative": 17,
		"dodge_chance": 0.10, "xp_reward": 10,
		"color": Color(0.9, 0.5, 0.5),
		"sprite_path": "res://assets/sprites/winged_quillhog.png",
	}), "res://data/monsters/cave/tier1/winged_swine.tres")

	_save(_monster("bristle_spitter", "Quill Spitter", 1, {
		"max_hp": 48, "damage": 14, "defense": 3, "initiative": 15,
		"dodge_chance": 0.03, "xp_reward": 10, "preferred_row": "back",
		"color": Color(0.7, 0.6, 0.4),
		"sprite_path": "res://assets/sprites/quill_spitter.png",
	}), "res://data/monsters/cave/tier1/bristle_spitter.tres")

	_save(_monster("truffle_zombie", "Zombie Hedgehog", 1, {
		"max_hp": 60, "damage": 13, "defense": 4, "initiative": 12,
		"xp_reward": 12,
		"color": Color(0.4, 0.55, 0.3),
		"sprite_path": "res://assets/sprites/zombie_hedgehog.png",
	}), "res://data/monsters/cave/tier1/truffle_zombie.tres")

	_save(_monster("oink_slime", "Quill Slime", 1, {
		"max_hp": 55, "damage": 12, "defense": 4, "initiative": 13,
		"xp_reward": 10,
		"color": Color(0.3, 0.7, 0.3),
		"sprite_path": "res://assets/sprites/quill_slime.png",
	}), "res://data/monsters/cave/tier1/oink_slime.tres")

	_save(_monster("ghost_piglet", "Ghost Hoglet", 1, {
		"max_hp": 42, "damage": 13, "defense": 2, "initiative": 18,
		"dodge_chance": 0.18, "xp_reward": 10,
		"color": Color(0.7, 0.8, 0.95),
		"sprite_path": "res://assets/sprites/ghost_hoglet.png",
	}), "res://data/monsters/cave/tier1/ghost_piglet.tres")

	_save(_monster("tuskling", "Spikeling", 1, {
		"max_hp": 48, "damage": 13, "defense": 4, "initiative": 16,
		"xp_reward": 10,
		"color": Color(0.5, 0.35, 0.25),
		"sprite_path": "res://assets/sprites/spikeling.png",
	}), "res://data/monsters/cave/tier1/tuskling.tres")

	# -- Tier 2 --

	var shield_bash: Resource = load("res://data/abilities/monster/shield_bash.tres")
	var smash: Resource = load("res://data/abilities/monster/smash.tres")
	var heal_ally: Resource = load("res://data/abilities/monster/heal_ally.tres")
	var iron_hide: Resource = load("res://data/abilities/monster/iron_hide.tres")
	var gore_ab: Resource = load("res://data/abilities/monster/gore.tres")
	var life_drain_ab: Resource = load("res://data/abilities/monster/life_drain.tres")

	_save(_monster("war_boar", "War Hedgehog", 2, {
		"max_hp": 120, "damage": 22, "defense": 10, "initiative": 18,
		"crit_chance": 0.08, "abilities": [shield_bash] as Array[Resource], "xp_reward": 20,
		"color": Color(0.6, 0.2, 0.2),
		"sprite_path": "res://assets/sprites/war_hedgehog.png",
	}), "res://data/monsters/cave/tier2/war_boar.tres")

	_save(_monster("hog_troll", "Quill Troll", 2, {
		"max_hp": 115, "damage": 26, "defense": 9, "initiative": 17,
		"crit_chance": 0.10, "abilities": [smash] as Array[Resource], "xp_reward": 22,
		"color": Color(0.4, 0.5, 0.35),
		"sprite_path": "res://assets/sprites/quill_troll.png",
	}), "res://data/monsters/cave/tier2/hog_troll.tres")

	_save(_monster("swinomancer", "Spinomancer", 2, {
		"max_hp": 95, "damage": 18, "defense": 6, "initiative": 22,
		"crit_chance": 0.08, "abilities": [heal_ally] as Array[Resource], "xp_reward": 18,
		"preferred_row": "back",
		"color": Color(0.55, 0.3, 0.65),
		"sprite_path": "res://assets/sprites/spinomancer.png",
	}), "res://data/monsters/cave/tier2/swinomancer.tres")

	_save(_monster("iron_boar", "Iron Hedgehog", 2, {
		"max_hp": 110, "damage": 24, "defense": 12, "initiative": 19,
		"crit_chance": 0.08, "abilities": [iron_hide] as Array[Resource], "xp_reward": 20,
		"color": Color(0.5, 0.5, 0.55),
		"sprite_path": "res://assets/sprites/iron_hedgehog.png",
	}), "res://data/monsters/cave/tier2/iron_boar.tres")

	_save(_monster("dire_tusker", "Dire Quillbeast", 2, {
		"max_hp": 105, "damage": 28, "defense": 8, "initiative": 23,
		"crit_chance": 0.12, "abilities": [gore_ab] as Array[Resource], "xp_reward": 22,
		"color": Color(0.45, 0.3, 0.2),
		"sprite_path": "res://assets/sprites/dire_quillbeast.png",
	}), "res://data/monsters/cave/tier2/dire_tusker.tres")

	_save(_monster("pork_wraith", "Quill Wraith", 2, {
		"max_hp": 90, "damage": 24, "defense": 5, "initiative": 24,
		"dodge_chance": 0.15, "crit_chance": 0.10,
		"abilities": [life_drain_ab] as Array[Resource], "xp_reward": 20,
		"preferred_row": "back",
		"color": Color(0.4, 0.2, 0.5),
		"sprite_path": "res://assets/sprites/quill_wraith.png",
	}), "res://data/monsters/cave/tier2/pork_wraith.tres")

	# -- Boss --

	var earthquake: Resource = load("res://data/abilities/monster/earthquake.tres")
	var flame_snort: Resource = load("res://data/abilities/monster/flame_snort.tres")
	var lava_spit: Resource = load("res://data/abilities/monster/lava_spit.tres")

	var hogzilla: Resource = MonsterScript.new()
	hogzilla.id = "hogzilla"
	hogzilla.display_name = "Hogzilla, the Eternal Quill"
	hogzilla.tier = 3
	hogzilla.max_hp = 250
	hogzilla.damage = 26
	hogzilla.defense = 12
	hogzilla.initiative = 20
	hogzilla.dodge_chance = 0.05
	hogzilla.crit_chance = 0.12
	hogzilla.crit_multiplier = 2.2
	hogzilla.abilities = [earthquake, flame_snort] as Array[Resource]
	hogzilla.preferred_row = "front"
	hogzilla.is_boss = true
	hogzilla.phase2_hp_percent = 0.5
	hogzilla.phase2_abilities = [lava_spit] as Array[Resource]
	hogzilla.phase2_stat_multiplier = 1.3
	hogzilla.xp_reward = 80
	hogzilla.color = Color(0.8, 0.3, 0.1)
	hogzilla.sprite_path = "res://assets/sprites/hogzilla.png"
	_save(hogzilla, "res://data/monsters/cave/boss/hogzilla.tres")

	print("  Created monsters.")


# ---------- Encounters ----------

func _create_encounters() -> void:
	_ensure_dir("res://data/encounters/cave")

	var hoglet: Resource = load("res://data/monsters/cave/tier1/hoglet.tres")
	var mud_hog: Resource = load("res://data/monsters/cave/tier1/mud_hog.tres")
	var tuskling: Resource = load("res://data/monsters/cave/tier1/tuskling.tres")
	var bristle_spitter: Resource = load("res://data/monsters/cave/tier1/bristle_spitter.tres")
	var war_boar: Resource = load("res://data/monsters/cave/tier2/war_boar.tres")
	var swinomancer: Resource = load("res://data/monsters/cave/tier2/swinomancer.tres")
	var iron_boar: Resource = load("res://data/monsters/cave/tier2/iron_boar.tres")
	var dire_tusker: Resource = load("res://data/monsters/cave/tier2/dire_tusker.tres")
	var pork_wraith: Resource = load("res://data/monsters/cave/tier2/pork_wraith.tres")
	var hogzilla: Resource = load("res://data/monsters/cave/boss/hogzilla.tres")

	var ghost_piglet: Resource = load("res://data/monsters/cave/tier1/ghost_piglet.tres")
	var oink_slime: Resource = load("res://data/monsters/cave/tier1/oink_slime.tres")
	var truffle_zombie: Resource = load("res://data/monsters/cave/tier1/truffle_zombie.tres")
	var winged_swine: Resource = load("res://data/monsters/cave/tier1/winged_swine.tres")
	var hog_troll: Resource = load("res://data/monsters/cave/tier2/hog_troll.tres")

	# --- Easy encounters (tier 1, 1-3 enemies) ---

	_save(_encounter("cave_easy_1", "Spiny Ambush", {
		"difficulty": "easy",
		"monsters": [hoglet, hoglet, hoglet, mud_hog] as Array[Resource],
		"formation": ["front", "front", "back", "front"] as Array[String],
	}), "res://data/encounters/cave/easy_1.tres")

	_save(_encounter("cave_easy_2", "Lone Mud Hog", {
		"difficulty": "easy",
		"monsters": [mud_hog] as Array[Resource],
		"formation": ["front"] as Array[String],
	}), "res://data/encounters/cave/easy_2.tres")

	_save(_encounter("cave_easy_3", "Ghostly Piglets", {
		"difficulty": "easy",
		"monsters": [ghost_piglet, ghost_piglet] as Array[Resource],
		"formation": ["front", "back"] as Array[String],
	}), "res://data/encounters/cave/easy_3.tres")

	_save(_encounter("cave_easy_4", "Slime Pit", {
		"difficulty": "easy",
		"monsters": [oink_slime, oink_slime] as Array[Resource],
		"formation": ["front", "front"] as Array[String],
	}), "res://data/encounters/cave/easy_4.tres")

	_save(_encounter("cave_easy_5", "Tuskling Patrol", {
		"difficulty": "easy",
		"monsters": [tuskling, hoglet] as Array[Resource],
		"formation": ["front", "back"] as Array[String],
	}), "res://data/encounters/cave/easy_5.tres")

	# --- Medium encounters (tier 1 + tier 2 mix, 2-3 enemies) ---

	_save(_encounter("cave_medium_1", "Spikeling Warband", {
		"difficulty": "medium",
		"monsters": [tuskling, tuskling, war_boar, bristle_spitter] as Array[Resource],
		"formation": ["front", "front", "front", "back"] as Array[String],
	}), "res://data/encounters/cave/medium_1.tres")

	_save(_encounter("cave_medium_2", "Tusker's Guard", {
		"difficulty": "medium",
		"monsters": [dire_tusker, hoglet, hoglet] as Array[Resource],
		"formation": ["front", "back", "back"] as Array[String],
	}), "res://data/encounters/cave/medium_2.tres")

	_save(_encounter("cave_medium_3", "The Swinomancer's Flock", {
		"difficulty": "medium",
		"monsters": [swinomancer, oink_slime, oink_slime] as Array[Resource],
		"formation": ["back", "front", "front"] as Array[String],
	}), "res://data/encounters/cave/medium_3.tres")

	_save(_encounter("cave_medium_4", "Undead Hog Pit", {
		"difficulty": "medium",
		"monsters": [truffle_zombie, truffle_zombie, ghost_piglet] as Array[Resource],
		"formation": ["front", "front", "back"] as Array[String],
	}), "res://data/encounters/cave/medium_4.tres")

	_save(_encounter("cave_medium_5", "Flying Ambush", {
		"difficulty": "medium",
		"monsters": [war_boar, winged_swine, bristle_spitter] as Array[Resource],
		"formation": ["front", "back", "back"] as Array[String],
	}), "res://data/encounters/cave/medium_5.tres")

	# --- Hard encounters (tier 2, 2-4 enemies) ---

	_save(_encounter("cave_hard_1", "The Quill Gauntlet", {
		"difficulty": "hard",
		"monsters": [dire_tusker, swinomancer, pork_wraith, iron_boar] as Array[Resource],
		"formation": ["front", "back", "back", "front"] as Array[String],
	}), "res://data/encounters/cave/hard_1.tres")

	_save(_encounter("cave_hard_2", "Iron Brigade", {
		"difficulty": "hard",
		"monsters": [iron_boar, iron_boar, pork_wraith] as Array[Resource],
		"formation": ["front", "front", "back"] as Array[String],
	}), "res://data/encounters/cave/hard_2.tres")

	_save(_encounter("cave_hard_3", "Troll's Kitchen", {
		"difficulty": "hard",
		"monsters": [hog_troll, swinomancer] as Array[Resource],
		"formation": ["front", "back"] as Array[String],
	}), "res://data/encounters/cave/hard_3.tres")

	_save(_encounter("cave_hard_4", "Dire Pack", {
		"difficulty": "hard",
		"monsters": [dire_tusker, war_boar, war_boar] as Array[Resource],
		"formation": ["front", "front", "front"] as Array[String],
	}), "res://data/encounters/cave/hard_4.tres")

	# --- Boss encounters ---

	_save(_encounter("cave_boss", "Hogzilla's Den", {
		"difficulty": "boss",
		"monsters": [hogzilla] as Array[Resource],
		"formation": ["front"] as Array[String],
	}), "res://data/encounters/cave/boss.tres")

	_save(_encounter("cave_boss_hard", "Hogzilla's Court", {
		"difficulty": "boss",
		"monsters": [hogzilla, war_boar, swinomancer] as Array[Resource],
		"formation": ["front", "front", "back"] as Array[String],
	}), "res://data/encounters/cave/boss_hard.tres")

	print("  Created encounters.")


# ---------- Test Heroes ----------

func _create_test_heroes() -> void:
	_ensure_dir("res://data/heroes")

	var human: Resource = load("res://data/races/human.tres")
	var elf: Resource = load("res://data/races/elf.tres")
	var dwarf: Resource = load("res://data/races/dwarf.tres")

	var warrior_class: Resource = load("res://data/classes/warrior.tres")
	var mage_class: Resource = load("res://data/classes/mage.tres")
	var rogue_class: Resource = load("res://data/classes/rogue.tres")
	var cleric_class: Resource = load("res://data/classes/cleric.tres")

	var iron_sword: Resource = load("res://data/equipment/weapons/iron_sword.tres")
	var plate_armor: Resource = load("res://data/equipment/armor/plate_armor.tres")
	var gnarled_staff: Resource = load("res://data/equipment/weapons/gnarled_staff.tres")
	var mage_robe: Resource = load("res://data/equipment/armor/mage_robe.tres")
	var twin_daggers: Resource = load("res://data/equipment/weapons/twin_daggers.tres")
	var leather_armor: Resource = load("res://data/equipment/armor/leather_armor.tres")
	var holy_mace: Resource = load("res://data/equipment/weapons/holy_mace.tres")
	var chain_vestments: Resource = load("res://data/equipment/armor/chain_vestments.tres")

	_save(_unit("hero_warrior", "Brock the Bold", {
		"race": human, "unit_class": warrior_class, "level": 3,
		"equipment": [iron_sword, plate_armor] as Array[Resource],
	}), "res://data/heroes/test_warrior.tres")

	_save(_unit("hero_mage", "Elara the Unhinged", {
		"race": elf, "unit_class": mage_class, "level": 3,
		"equipment": [gnarled_staff, mage_robe] as Array[Resource],
	}), "res://data/heroes/test_mage.tres")

	_save(_unit("hero_rogue", "Vex Shadowpocket", {
		"race": human, "unit_class": rogue_class, "level": 3,
		"equipment": [twin_daggers, leather_armor] as Array[Resource],
	}), "res://data/heroes/test_rogue.tres")

	_save(_unit("hero_cleric", "Thorin Lightbeard", {
		"race": dwarf, "unit_class": cleric_class, "level": 3,
		"equipment": [holy_mace, chain_vestments] as Array[Resource],
	}), "res://data/heroes/test_cleric.tres")

	print("  Created test heroes.")


# ---------- Helpers ----------

func _ability(id: String, display_name: String, description: String, props: Dictionary) -> Resource:
	var ab: Resource = AbilityScript.new()
	ab.id = id
	ab.display_name = display_name
	ab.description = description

	for key: String in props:
		ab.set(key, props[key])

	return ab


func _race(id: String, display_name: String, props: Dictionary) -> Resource:
	var r: Resource = RaceScript.new()
	r.id = id
	r.display_name = display_name

	for key: String in props:
		r.set(key, props[key])

	return r


func _class_data(id: String, display_name: String, props: Dictionary) -> Resource:
	var c: Resource = ClassScript.new()
	c.id = id
	c.display_name = display_name

	for key: String in props:
		c.set(key, props[key])

	return c


func _equipment(id: String, display_name: String, slot: String, rarity: String, required_class: String, bonuses: Dictionary) -> Resource:
	var eq: Resource = EquipmentScript.new()
	eq.id = id
	eq.display_name = display_name
	eq.slot = slot
	eq.rarity = rarity
	eq.required_class = required_class

	for key: String in bonuses:
		eq.set(key, bonuses[key])

	return eq


func _monster(id: String, display_name: String, tier: int, props: Dictionary) -> Resource:
	var m: Resource = MonsterScript.new()
	m.id = id
	m.display_name = display_name
	m.tier = tier

	for key: String in props:
		m.set(key, props[key])

	return m


func _encounter(id: String, display_name: String, props: Dictionary) -> Resource:
	var e: Resource = EncounterScript.new()
	e.id = id
	e.display_name = display_name

	for key: String in props:
		e.set(key, props[key])

	return e


func _unit(id: String, display_name: String, props: Dictionary) -> Resource:
	var u: Resource = UnitScript.new()
	u.id = id
	u.display_name = display_name

	for key: String in props:
		u.set(key, props[key])

	return u


func _save(resource: Resource, path: String) -> void:
	var err := ResourceSaver.save(resource, path)

	if err != OK:
		push_error("Failed to save: %s (error %d)" % [path, err])


func _ensure_dir(path: String) -> void:
	DirAccess.make_dir_recursive_absolute(path)
