class_name ClickHandler
extends Node

var grid_manager: GridManager


func _ready() -> void:
	grid_manager = get_parent() as GridManager


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var world_pos := grid_manager.get_global_mouse_position()
		var local_pos := grid_manager.to_local(world_pos)
		var cell := grid_manager.world_to_grid_elevated(local_pos)

		if grid_manager.is_valid_cell(cell):
			var h: int = grid_manager.height_map.get(cell, 0)
			print("Clicked cell: ", cell, " (height: ", h, ")")
			EventBus.tile_clicked.emit(cell)
