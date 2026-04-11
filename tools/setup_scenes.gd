@tool
extends SceneTree

## Generates .tscn scene files.
## Run with: godot --headless --script res://tools/setup_scenes.gd

func _init() -> void:
	_create_unit_slot_scene()
	_create_battle_scene()
	_create_dungeon_map_scene()
	_create_main_scene()

	# Scripts can't be loaded in headless mode (autoloads unavailable),
	# so we patch the saved tscn files to inject script references.
	_patch_scene_scripts("res://scenes/ui/unit_slot.tscn", {
		"UnitSlot": "res://scripts/ui/unit_slot_ui.gd",
	})
	_patch_scene_scripts("res://scenes/battle/battle.tscn", {
		"BattleCamera": "res://scripts/battle/battle_camera.gd",
		"BattleManager": "res://scripts/battle/battle_manager.gd",
		"BattleUI": "res://scripts/ui/battle_ui.gd",
	})
	_patch_scene_scripts("res://scenes/dungeon/dungeon_map.tscn", {
		"DungeonMap": "res://scripts/ui/dungeon_map_ui.gd",
	})
	_patch_scene_scripts("res://scenes/main.tscn", {
		"Main": "res://scripts/main.gd",
		"DungeonManager": "res://scripts/dungeon/dungeon_manager.gd",
	})

	print("Scene setup complete.")
	quit()


func _try_load_script(_path: String) -> Resource:
	## In headless --script mode, GDScript resources with autoload references
	## can't be loaded. Scripts are injected via _patch_scene_scripts() instead.
	return null


# ---------- Unit Slot Scene ----------

func _create_unit_slot_scene() -> void:
	_ensure_dir("res://scenes/ui")

	var dead_texture: Texture2D = load("res://assets/sprites/bones_pile.png")

	var root := PanelContainer.new()
	root.name = "UnitSlot"
	root.set_script(_try_load_script("res://scripts/ui/unit_slot_ui.gd"))
	root.custom_minimum_size = Vector2(210, 0)
	root.clip_contents = false
	root.add_theme_stylebox_override("panel", StyleBoxEmpty.new())

	var vbox := VBoxContainer.new()
	vbox.name = "VBox"
	vbox.add_theme_constant_override("separation", 0)
	root.add_child(vbox)
	vbox.owner = root

	# Sprite container
	var sprite_cont := Control.new()
	sprite_cont.name = "SpriteContainer"
	sprite_cont.custom_minimum_size = Vector2(210, 270)
	sprite_cont.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(sprite_cont)
	sprite_cont.owner = root

	var sprite := TextureRect.new()
	sprite.name = "Sprite"
	sprite.unique_name_in_owner = true
	sprite.set_anchors_preset(Control.PRESET_FULL_RECT)
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	sprite_cont.add_child(sprite)
	sprite.owner = root

	var dead_sprite := TextureRect.new()
	dead_sprite.name = "DeadSprite"
	dead_sprite.unique_name_in_owner = true
	dead_sprite.visible = false
	dead_sprite.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	dead_sprite.offset_left = -110
	dead_sprite.offset_top = -180
	dead_sprite.offset_right = 110
	dead_sprite.texture = dead_texture
	dead_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	dead_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	dead_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	sprite_cont.add_child(dead_sprite)
	dead_sprite.owner = root

	# HP bar with horizontal margins
	var hp_margin := MarginContainer.new()
	hp_margin.name = "HpMargin"
	hp_margin.add_theme_constant_override("margin_left", 8)
	hp_margin.add_theme_constant_override("margin_right", 8)
	hp_margin.add_theme_constant_override("margin_top", 0)
	hp_margin.add_theme_constant_override("margin_bottom", 0)
	vbox.add_child(hp_margin)
	hp_margin.owner = root

	var hp_cont := Control.new()
	hp_cont.name = "HpContainer"
	hp_cont.custom_minimum_size = Vector2(194, 18)
	hp_cont.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	hp_margin.add_child(hp_cont)
	hp_cont.owner = root

	var hp_bar := ProgressBar.new()
	hp_bar.name = "HpBar"
	hp_bar.unique_name_in_owner = true
	hp_bar.set_anchors_preset(Control.PRESET_FULL_RECT)
	hp_bar.show_percentage = false
	hp_cont.add_child(hp_bar)
	hp_bar.owner = root

	var hp_label := Label.new()
	hp_label.name = "HpLabel"
	hp_label.unique_name_in_owner = true
	hp_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hp_label.add_theme_font_size_override("font_size", 10)
	hp_label.add_theme_color_override("font_color", Color.WHITE)
	hp_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	hp_label.add_theme_constant_override("shadow_offset_x", 1)
	hp_label.add_theme_constant_override("shadow_offset_y", 1)
	hp_cont.add_child(hp_label)
	hp_label.owner = root

	var scene := PackedScene.new()
	scene.pack(root)
	ResourceSaver.save(scene, "res://scenes/ui/unit_slot.tscn")
	print("Created: scenes/ui/unit_slot.tscn")

	root.free()


# ---------- Battle Scene ----------

func _create_battle_scene() -> void:
	_ensure_dir("res://scenes/battle")

	var unit_slot_scene: PackedScene = load("res://scenes/ui/unit_slot.tscn")

	var root := Node2D.new()
	root.name = "Battle"

	# Camera
	var camera := Camera2D.new()
	camera.name = "BattleCamera"
	camera.set_script(_try_load_script("res://scripts/battle/battle_camera.gd"))
	root.add_child(camera)
	camera.owner = root

	# BattleManager
	var battle_manager := Node.new()
	battle_manager.name = "BattleManager"
	battle_manager.set_script(_try_load_script("res://scripts/battle/battle_manager.gd"))
	root.add_child(battle_manager)
	battle_manager.owner = root

	# BattleUI (CanvasLayer)
	var battle_ui := CanvasLayer.new()
	battle_ui.name = "BattleUI"
	battle_ui.set_script(_try_load_script("res://scripts/ui/battle_ui.gd"))
	root.add_child(battle_ui)
	battle_ui.owner = root

	# Background
	var bg_texture: Texture2D = load("res://assets/tiles/cave_dungeon_bg.png")

	var bg := TextureRect.new()
	bg.name = "Background"
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.texture = bg_texture
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	battle_ui.add_child(bg)
	bg.owner = root

	# Screen VBox
	var screen := VBoxContainer.new()
	screen.name = "Screen"
	screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	screen.add_theme_constant_override("separation", 0)
	battle_ui.add_child(screen)
	screen.owner = root

	# -- Top bar --
	var top_margin := MarginContainer.new()
	top_margin.name = "TopMargin"
	top_margin.add_theme_constant_override("margin_left", 16)
	top_margin.add_theme_constant_override("margin_right", 16)
	top_margin.add_theme_constant_override("margin_top", 8)
	top_margin.add_theme_constant_override("margin_bottom", 4)
	screen.add_child(top_margin)
	top_margin.owner = root

	var top_bar := HBoxContainer.new()
	top_bar.name = "TopBar"
	top_bar.add_theme_constant_override("separation", 20)
	top_margin.add_child(top_bar)
	top_bar.owner = root

	var round_label := Label.new()
	round_label.name = "RoundLabel"
	round_label.unique_name_in_owner = true
	round_label.text = "Round 0"
	round_label.add_theme_font_size_override("font_size", 20)
	top_bar.add_child(round_label)
	round_label.owner = root

	var spacer := Control.new()
	spacer.name = "Spacer"
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(spacer)
	spacer.owner = root

	var speed_box := HBoxContainer.new()
	speed_box.name = "SpeedBox"
	speed_box.add_theme_constant_override("separation", 5)
	top_bar.add_child(speed_box)
	speed_box.owner = root

	for btn_data: Array in [["PauseBtn", "||"], ["PlayBtn", ">"], ["FastBtn", ">>"], ["FastestBtn", ">>>"]]:
		var btn := Button.new()
		btn.name = btn_data[0]
		btn.text = btn_data[1]
		speed_box.add_child(btn)
		btn.owner = root

	var speed_label := Label.new()
	speed_label.name = "SpeedLabel"
	speed_label.unique_name_in_owner = true
	speed_label.text = "1x"
	speed_label.add_theme_font_size_override("font_size", 14)
	speed_box.add_child(speed_label)
	speed_label.owner = root

	# -- Log toggle --
	var log_header_margin := MarginContainer.new()
	log_header_margin.name = "LogHeaderMargin"
	log_header_margin.add_theme_constant_override("margin_left", 8)
	log_header_margin.add_theme_constant_override("margin_right", 8)
	screen.add_child(log_header_margin)
	log_header_margin.owner = root

	var log_toggle := Button.new()
	log_toggle.name = "LogToggle"
	log_toggle.unique_name_in_owner = true
	log_toggle.toggle_mode = true
	log_toggle.button_pressed = false
	log_toggle.text = "> Log"
	log_header_margin.add_child(log_toggle)
	log_toggle.owner = root

	# -- Log area --
	var log_margin := MarginContainer.new()
	log_margin.name = "LogMargin"
	log_margin.unique_name_in_owner = true
	log_margin.visible = false
	log_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	log_margin.add_theme_constant_override("margin_left", 12)
	log_margin.add_theme_constant_override("margin_right", 12)
	screen.add_child(log_margin)
	log_margin.owner = root

	var log_panel := PanelContainer.new()
	log_panel.name = "LogPanel"
	log_panel.unique_name_in_owner = true
	log_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	log_margin.add_child(log_panel)
	log_panel.owner = root

	var log_scroll := ScrollContainer.new()
	log_scroll.name = "LogScroll"
	log_scroll.unique_name_in_owner = true
	log_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	log_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	log_panel.add_child(log_scroll)
	log_scroll.owner = root

	var log_text_margin := MarginContainer.new()
	log_text_margin.name = "LogTextMargin"
	log_text_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	log_text_margin.add_theme_constant_override("margin_left", 8)
	log_text_margin.add_theme_constant_override("margin_top", 4)
	log_text_margin.add_theme_constant_override("margin_bottom", 4)
	log_scroll.add_child(log_text_margin)
	log_text_margin.owner = root

	var log_text := RichTextLabel.new()
	log_text.name = "LogText"
	log_text.unique_name_in_owner = true
	log_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	log_text.bbcode_enabled = true
	log_text.fit_content = true
	log_text.scroll_active = false
	log_text_margin.add_child(log_text)
	log_text.owner = root

	# -- Bottom spacer --
	var bottom_spacer := Control.new()
	bottom_spacer.name = "BottomSpacer"
	bottom_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	screen.add_child(bottom_spacer)
	bottom_spacer.owner = root

	# -- Formation area (with hero/monster margins) --
	var formation_margin := MarginContainer.new()
	formation_margin.name = "FormationMargin"
	formation_margin.add_theme_constant_override("margin_left", 40)
	formation_margin.add_theme_constant_override("margin_right", 40)
	formation_margin.add_theme_constant_override("margin_top", 0)
	formation_margin.add_theme_constant_override("margin_bottom", 140)
	screen.add_child(formation_margin)
	formation_margin.owner = root

	var formation_area := HBoxContainer.new()
	formation_area.name = "FormationArea"
	formation_area.alignment = BoxContainer.ALIGNMENT_CENTER
	formation_area.add_theme_constant_override("separation", 0)
	formation_margin.add_child(formation_area)
	formation_area.owner = root

	# Hero row
	var hero_row := HBoxContainer.new()
	hero_row.name = "HeroRow"
	hero_row.add_theme_constant_override("separation", 0)
	formation_area.add_child(hero_row)
	hero_row.owner = root

	for i: int in 4:
		var slot: Node = unit_slot_scene.instantiate()
		slot.name = "HeroSlot%d" % i
		slot.unique_name_in_owner = true
		hero_row.add_child(slot)
		slot.owner = root

	# Mid spacer between heroes and monsters
	var mid_spacer := Control.new()
	mid_spacer.name = "MidSpacer"
	mid_spacer.custom_minimum_size = Vector2(80, 0)
	formation_area.add_child(mid_spacer)
	mid_spacer.owner = root

	# Monster row
	var monster_row := HBoxContainer.new()
	monster_row.name = "MonsterRow"
	monster_row.add_theme_constant_override("separation", 0)
	formation_area.add_child(monster_row)
	monster_row.owner = root

	for i: int in 4:
		var slot: Node = unit_slot_scene.instantiate()
		slot.name = "MonsterSlot%d" % i
		slot.unique_name_in_owner = true
		monster_row.add_child(slot)
		slot.owner = root

	# -- Result overlay --
	var result_overlay := ColorRect.new()
	result_overlay.name = "ResultOverlay"
	result_overlay.unique_name_in_owner = true
	result_overlay.visible = false
	result_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	result_overlay.color = Color(0, 0, 0, 0.7)
	result_overlay.mouse_filter = Control.MOUSE_FILTER_PASS
	battle_ui.add_child(result_overlay)
	result_overlay.owner = root

	var result_label := Label.new()
	result_label.name = "ResultLabel"
	result_label.unique_name_in_owner = true
	result_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	result_label.add_theme_font_size_override("font_size", 48)
	result_overlay.add_child(result_label)
	result_label.owner = root

	var scene := PackedScene.new()
	scene.pack(root)
	ResourceSaver.save(scene, "res://scenes/battle/battle.tscn")
	print("Created: scenes/battle/battle.tscn")

	root.free()


# ---------- Dungeon Map Scene ----------

func _create_dungeon_map_scene() -> void:
	_ensure_dir("res://scenes/dungeon")

	var root := Control.new()
	root.name = "DungeonMap"
	root.set_script(_try_load_script("res://scripts/ui/dungeon_map_ui.gd"))
	root.set_anchors_preset(Control.PRESET_FULL_RECT)

	var scene := PackedScene.new()
	scene.pack(root)
	ResourceSaver.save(scene, "res://scenes/dungeon/dungeon_map.tscn")
	print("Created: scenes/dungeon/dungeon_map.tscn")

	root.free()


# ---------- Main Scene ----------

func _create_main_scene() -> void:
	var dungeon_map_scene: PackedScene = load("res://scenes/dungeon/dungeon_map.tscn")

	var root := Control.new()
	root.name = "Main"
	root.set_script(_try_load_script("res://scripts/main.gd"))
	root.set_anchors_preset(Control.PRESET_FULL_RECT)

	# Content area — top 75% of the screen for battle/party view
	var content_area := Control.new()
	content_area.name = "ContentArea"
	content_area.set_anchors_preset(Control.PRESET_TOP_WIDE)
	content_area.anchor_bottom = 0.75
	content_area.offset_bottom = 0
	root.add_child(content_area)
	content_area.owner = root

	# Dungeon map bar — bottom 25%
	var map_bar := PanelContainer.new()
	map_bar.name = "MapBar"
	map_bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	map_bar.anchor_top = 0.75
	map_bar.offset_top = 0
	root.add_child(map_bar)
	map_bar.owner = root

	var map_instance: Node = dungeon_map_scene.instantiate()
	map_instance.name = "DungeonMap"
	map_bar.add_child(map_instance)
	map_instance.owner = root

	# DungeonManager (logic node)
	var dungeon_manager := Node.new()
	dungeon_manager.name = "DungeonManager"
	dungeon_manager.set_script(_try_load_script("res://scripts/dungeon/dungeon_manager.gd"))
	root.add_child(dungeon_manager)
	dungeon_manager.owner = root

	var scene := PackedScene.new()
	scene.pack(root)
	ResourceSaver.save(scene, "res://scenes/main.tscn")
	print("Created: scenes/main.tscn")

	root.free()


# ---------- Helpers ----------

func _set_owner_recursive(node: Node, owner: Node) -> void:
	for child: Node in node.get_children():
		child.owner = owner
		_set_owner_recursive(child, owner)


func _ensure_dir(path: String) -> void:
	DirAccess.make_dir_recursive_absolute(path)


func _patch_scene_scripts(scene_path: String, scripts: Dictionary) -> void:
	## Injects script ext_resource references into a saved .tscn file.
	## scripts: { "NodeName": "res://path/to/script.gd", ... }
	var abs_path := ProjectSettings.globalize_path(scene_path)
	var content := FileAccess.get_file_as_string(abs_path)

	if content.is_empty():
		push_error("Cannot read scene file: %s" % scene_path)
		return

	# Build ext_resource entries for each script
	var ext_resources := ""
	var script_id_map := {}  # node_name -> ext_resource id
	var id_counter := 100

	for node_name: String in scripts:
		var script_path: String = scripts[node_name]
		var res_id := "script_%d" % id_counter
		ext_resources += "[ext_resource type=\"Script\" path=\"%s\" id=\"%s\"]\n" % [script_path, res_id]
		script_id_map[node_name] = res_id
		id_counter += 1

	# Insert ext_resources after the [gd_scene] header line
	var header_end := content.find("\n") + 1
	content = content.insert(header_end, "\n" + ext_resources)

	# Add script = ExtResource("id") to each target node
	for node_name: String in script_id_map:
		var res_id: String = script_id_map[node_name]

		# Find the node definition line
		var node_pattern := "[node name=\"%s\"" % node_name
		var node_pos := content.find(node_pattern)

		if node_pos == -1:
			push_warning("Node '%s' not found in %s" % [node_name, scene_path])
			continue

		# Find the end of this node's line
		var line_end := content.find("\n", node_pos)

		if line_end == -1:
			line_end = content.length()

		# Insert script property on the next line
		var script_line := "\nscript = ExtResource(\"%s\")" % res_id
		content = content.insert(line_end, script_line)

	# Write back
	var file := FileAccess.open(abs_path, FileAccess.WRITE)
	file.store_string(content)
	file.close()
	print("  Patched scripts into: %s" % scene_path)
