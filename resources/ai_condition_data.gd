class_name AIConditionData
extends Resource

## Declarative condition for ability AI triggers.
## Evaluated generically — no hardcoded condition strings.
##
## Scope determines WHO to check:
##   "always"      — unconditionally true
##   "self"        — evaluate property on the actor
##   "any_ally"    — true if ANY living ally matches
##   "any_enemy"   — true if ANY living enemy matches
##   "allies"      — group-level property on all allies
##   "enemies"     — group-level property on all enemies
##   "dead_allies" — group-level property on dead allies pool
##
## Property determines WHAT to measure:
##   Individual: "hp_pct", "has_negative_effect"
##   Group:      "alive_count", "count"
##
## Compare: "lt", "lte", "gt", "gte", "eq"

@export var scope: String = "always"
@export var property: String = ""
@export var compare: String = ""
@export var value: float = 0.0
