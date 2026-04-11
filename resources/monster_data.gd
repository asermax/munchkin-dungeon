class_name MonsterData
extends Resource

@export var id: String
@export var display_name: String
@export var tier: int = 1                       # 1, 2, or 3 (boss)

## Direct stats (not derived from primary stats like heroes)
@export var max_hp: int = 40
@export var damage: int = 10
@export var defense: int = 3
@export var initiative: int = 10
@export var dodge_chance: float = 0.0
@export var crit_chance: float = 0.08
@export var crit_multiplier: float = 2.0

## Abilities (empty for Tier 1, 1 for Tier 2, 2-3 for bosses)
@export var abilities: Array[Resource] = []

## Formation
@export var preferred_row: String = "front"

## Boss mechanics
@export var is_boss: bool = false
@export var phase2_hp_percent: float = 0.5
@export var phase2_abilities: Array[Resource] = []
@export var phase2_stat_multiplier: float = 1.0

## Rewards
@export var xp_reward: int = 10

## UI
@export var color: Color = Color.RED
@export var sprite_path: String = ""
