class_name AbilityData
extends Resource

@export var id: String
@export var display_name: String
@export var description: String

## Cooldown in rounds (0 = usable every turn)
@export var cooldown: int = 0

## Targeting
@export var target_type: String = "enemy"       # "enemy", "ally", "self", "all_enemies", "all_allies"
@export var reach: String = "melee"             # "melee", "ranged" — melee can only hit front row

## Effect
@export var effect_type: String = "damage"      # "damage", "heal", "buff", "debuff", "taunt", "resurrect"
@export var damage_stat: String = "str"         # "str" or "int" — which primary stat drives power
@export var power: float = 1.0                  # multiplier on stat (1.0 = normal, 1.5 = 150%)
@export var heal_amount: int = 0                # flat heal for heal-type abilities

## Secondary effect
@export var secondary_effect: String = ""       # "stun", "bleed", "poison", "defense_up", "dodge_up", etc.
@export var secondary_chance: float = 0.0
@export var secondary_duration: int = 0
@export var secondary_value: int = 0

## AI behavior
@export var ai_priority: int = 0                # higher = tried first in the priority tree
@export var ai_condition: Resource                # AIConditionData — declarative trigger condition
@export var ai_target_strategy: String = "weighted_random"  # "weighted_random", "lowest_hp", "lowest_hp_pct", "has_negative_effect", "front_row", "first_dead"
