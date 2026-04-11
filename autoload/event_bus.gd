class_name EventBusClass
extends Node

## Grid signals
signal tile_clicked(cell: Vector2i)
signal tile_hovered(cell: Vector2i)

## Unit signals
signal unit_selected(unit: Node2D)
signal unit_deselected()
signal unit_moved(unit: Node2D, from: Vector2i, to: Vector2i)
signal unit_damaged(unit: Node2D, amount: int)
signal unit_died(unit: Node2D)

## Battle signals
signal battle_started()
signal battle_ended()
signal turn_started(unit: Node2D)
signal turn_ended(unit: Node2D)

## Range display
signal movement_range_requested(cells: Dictionary)
signal attack_range_requested(cells: Array)
signal range_display_cleared()
