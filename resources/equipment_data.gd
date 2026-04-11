class_name EquipmentData
extends Resource

@export var id: String
@export var display_name: String
@export var slot: String = "weapon"             # "weapon", "armor", "hat", "boots"
@export var rarity: String = "common"           # "common", "uncommon", "rare", "legendary", "cursed"
@export var required_class: String = ""         # "" = any class can equip

## Primary stat bonuses (feed into derived stat formulas)
@export var bonus_str: int = 0
@export var bonus_agi: int = 0
@export var bonus_vit: int = 0
@export var bonus_int: int = 0
@export var bonus_luck: int = 0

## Direct derived stat bonuses
@export var bonus_damage: int = 0               # weapon_bonus in damage formula
@export var bonus_defense: int = 0              # armor_bonus in defense formula
@export var bonus_hp: int = 0                   # armor_bonus in max HP formula
@export var bonus_initiative: int = 0           # boots_bonus in initiative formula
