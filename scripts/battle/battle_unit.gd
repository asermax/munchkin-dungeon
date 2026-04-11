class_name BattleUnit
extends RefCounted

## Runtime wrapper for one combatant during battle.
## Created from UnitData (hero) or MonsterData (monster).

# Identity
var unit_id: String
var display_name: String
var is_hero: bool

# Source data
var unit_data: Resource        # UnitData, set for heroes
var monster_data: Resource     # MonsterData, set for monsters

# Position
var side: String               # "hero" or "enemy"
var row: String                # "front" or "back"
var slot: int                  # 0 or 1 within that row

# Computed stats
var max_hp: int
var damage: int
var magic_damage: int
var defense: int
var initiative: int
var dodge_chance: float
var crit_chance: float
var crit_multiplier: float
var trait_id: String = ""

# Live state
var current_hp: int
var is_alive: bool = true
var cooldowns: Dictionary = {}                    # ability_id -> rounds remaining
var active_effects: Array[Dictionary] = []        # {id, name, duration, value, type}
var color: Color = Color.WHITE
var sprite_path: String = ""

# Boss
var is_boss: bool = false
var is_in_phase2: bool = false
var phase2_hp_percent: float = 0.5
var phase2_stat_multiplier: float = 1.0
var phase2_abilities: Array = []

# Abilities (list of AbilityData resources)
var abilities: Array = []


static func from_hero(data: Resource, hero_side: String, hero_row: String, hero_slot: int) -> BattleUnit:
	var unit := BattleUnit.new()
	unit.unit_id = data.id
	unit.display_name = data.display_name
	unit.is_hero = true
	unit.unit_data = data
	unit.side = hero_side
	unit.row = hero_row
	unit.slot = hero_slot

	var stats: Dictionary = StatCalculator.compute_hero_stats(data)
	unit.max_hp = stats["max_hp"]
	unit.damage = stats["damage"]
	unit.magic_damage = stats["magic_damage"]
	unit.defense = stats["defense"]
	unit.initiative = stats["initiative"]
	unit.dodge_chance = stats["dodge_chance"]
	unit.crit_chance = stats["crit_chance"]
	unit.crit_multiplier = stats["crit_multiplier"]
	unit.trait_id = stats["trait_id"]
	unit.current_hp = unit.max_hp

	var unit_class: Resource = data.get("unit_class")
	unit.color = unit_class.get("color")
	unit.sprite_path = unit_class.get("sprite_path")
	unit.abilities = Array(unit_class.get("abilities"))

	return unit


static func from_monster(data: Resource, enemy_side: String, enemy_row: String, enemy_slot: int) -> BattleUnit:
	var unit := BattleUnit.new()
	unit.unit_id = data.id
	unit.display_name = data.display_name
	unit.is_hero = false
	unit.monster_data = data
	unit.side = enemy_side
	unit.row = enemy_row
	unit.slot = enemy_slot

	unit.max_hp = data.get("max_hp")
	unit.damage = data.get("damage")
	unit.magic_damage = 0
	unit.defense = data.get("defense")
	unit.initiative = data.get("initiative")
	unit.dodge_chance = data.get("dodge_chance")
	unit.crit_chance = data.get("crit_chance")
	unit.crit_multiplier = data.get("crit_multiplier")
	unit.current_hp = unit.max_hp

	unit.color = data.get("color")
	unit.sprite_path = data.get("sprite_path")
	unit.abilities = Array(data.get("abilities"))

	# Boss setup
	unit.is_boss = data.get("is_boss")
	unit.phase2_hp_percent = data.get("phase2_hp_percent")
	unit.phase2_stat_multiplier = data.get("phase2_stat_multiplier")
	unit.phase2_abilities = Array(data.get("phase2_abilities"))

	return unit


func take_damage(amount: int) -> int:
	var actual := mini(amount, current_hp)
	current_hp -= actual

	if current_hp <= 0:
		current_hp = 0
		is_alive = false

	return actual


func heal(amount: int) -> int:
	var actual := mini(amount, max_hp - current_hp)
	current_hp += actual
	return actual


func tick_cooldowns() -> void:
	var to_remove: Array[String] = []

	for ability_id: String in cooldowns:
		cooldowns[ability_id] -= 1

		if cooldowns[ability_id] <= 0:
			to_remove.append(ability_id)

	for ability_id: String in to_remove:
		cooldowns.erase(ability_id)


func tick_effects() -> Array[Dictionary]:
	## Processes DoT/buff expiry. Returns array of expired/triggered effect info.
	var results: Array[Dictionary] = []
	var to_remove: Array[int] = []

	for i in range(active_effects.size()):
		var effect: Dictionary = active_effects[i]

		# Tick DoT effects
		if effect.type == "bleed" or effect.type == "poison":
			var dot_damage := take_damage(effect.value)

			results.append({
				"effect": effect.type,
				"damage": dot_damage,
				"unit_id": unit_id,
			})

		effect.duration -= 1

		if effect.duration <= 0:
			to_remove.append(i)

	# Remove expired effects in reverse order
	to_remove.reverse()

	for i: int in to_remove:
		remove_effect(i)

	return results


func remove_effect(index: int) -> void:
	## Removes an effect at the given index, reverting any stat changes it applied.
	var effect: Dictionary = active_effects[index]
	_revert_effect_stats(effect)
	active_effects.remove_at(index)


func is_ability_ready(ability_id: String) -> bool:
	return not cooldowns.has(ability_id)


func use_ability(ability_id: String, cooldown_turns: int) -> void:
	if cooldown_turns > 0:
		cooldowns[ability_id] = cooldown_turns


## Maps buff effect types to their stat property and scale factor.
## Apply: property += value * scale. Revert: property -= value * scale.
const BUFF_STAT_MAP: Dictionary = {
	"defense_up": {"property": &"defense", "scale": 1.0},
	"damage_up": {"property": &"damage", "scale": 1.0},
	"dodge_up": {"property": &"dodge_chance", "scale": 0.01},
}


func apply_effect(effect_id: String, effect_name: String, duration: int, value: int, type: String) -> void:
	_apply_effect_stats(type, value)

	active_effects.append({
		"id": effect_id,
		"name": effect_name,
		"duration": duration,
		"value": value,
		"type": type,
	})


func _apply_effect_stats(type: String, value: int) -> void:
	if type in BUFF_STAT_MAP:
		var meta: Dictionary = BUFF_STAT_MAP[type]
		set(meta.property, get(meta.property) + value * meta.scale)


func _revert_effect_stats(effect: Dictionary) -> void:
	if effect.type in BUFF_STAT_MAP:
		var meta: Dictionary = BUFF_STAT_MAP[effect.type]
		set(meta.property, get(meta.property) - effect.value * meta.scale)


func has_effect(effect_type: String) -> bool:
	for effect: Dictionary in active_effects:
		if effect.type == effect_type:
			return true

	return false


func has_negative_effect() -> bool:
	for effect: Dictionary in active_effects:
		if effect.type in ["bleed", "poison", "stun", "accuracy_down"]:
			return true

	return false


func is_stunned() -> bool:
	for effect: Dictionary in active_effects:
		if effect.type == "stun":
			return true

	return false


func check_phase2() -> bool:
	## Returns true if boss just transitioned to phase 2.
	if not is_boss or is_in_phase2:
		return false

	if float(current_hp) / float(max_hp) <= phase2_hp_percent:
		is_in_phase2 = true

		# Boost stats
		damage = floori(damage * phase2_stat_multiplier)
		defense = floori(defense * phase2_stat_multiplier)

		# Add phase 2 abilities
		for ab: Resource in phase2_abilities:
			abilities.append(ab)

		return true

	return false


func get_display_info() -> Dictionary:
	return {
		"unit_id": unit_id,
		"display_name": display_name,
		"is_hero": is_hero,
		"side": side,
		"row": row,
		"slot": slot,
		"current_hp": current_hp,
		"max_hp": max_hp,
		"is_alive": is_alive,
		"color": color,
		"sprite_path": sprite_path,
		"is_boss": is_boss,
		"is_in_phase2": is_in_phase2,
		"active_effects": active_effects.duplicate(),
	}
