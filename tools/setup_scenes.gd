@tool
extends SceneTree

## Generates .tscn scene files using Godot's serializer.
##
## Some scripts reference autoload singletons (EventBus, GameState) which
## aren't available during --script execution. We load those scripts with
## error handling and attach them even if they fail validation — Godot will
## resolve autoloads at runtime when the project actually runs.


func _init() -> void:
	_create_battlefield_scene()
	_create_main_scene()
	print("Scene setup complete.")
	quit()


func _try_load_script(path: String) -> GDScript:
	var script := GDScript.new()
	script.source_code = FileAccess.get_file_as_string(path)
	script.resource_path = path

	# We don't call reload() — the script may fail to compile in headless
	# mode due to missing autoloads. That's fine; Godot will resolve it
	# when running the project normally.
	return script


func _create_battlefield_scene() -> void:
	var battlefield := Node2D.new()
	battlefield.name = "Battlefield"

	# GridManager
	var grid_manager := Node2D.new()
	grid_manager.name = "GridManager"
	grid_manager.set_script(_try_load_script("res://scripts/grid/grid_manager.gd"))
	battlefield.add_child(grid_manager)
	grid_manager.owner = battlefield

	# ClickHandler
	var click_handler := Node.new()
	click_handler.name = "ClickHandler"
	click_handler.set_script(_try_load_script("res://scripts/grid/click_handler.gd"))
	grid_manager.add_child(click_handler)
	click_handler.owner = battlefield

	var scene := PackedScene.new()
	scene.pack(battlefield)
	ResourceSaver.save(scene, "res://scenes/battle/battlefield.tscn")
	print("Created: scenes/battle/battlefield.tscn")

	battlefield.free()


func _create_main_scene() -> void:
	var main := Node2D.new()
	main.name = "Main"

	# Camera
	var camera := Camera2D.new()
	camera.name = "BattleCamera"
	camera.set_script(_try_load_script("res://scripts/battle/battle_camera.gd"))
	main.add_child(camera)
	camera.owner = main

	# Instance the battlefield
	var battlefield_scene: PackedScene = load("res://scenes/battle/battlefield.tscn")
	var battlefield := battlefield_scene.instantiate()
	main.add_child(battlefield)
	battlefield.owner = main

	var scene := PackedScene.new()
	scene.pack(main)
	ResourceSaver.save(scene, "res://scenes/main.tscn")
	print("Created: scenes/main.tscn")

	main.free()
