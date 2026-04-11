class_name PartyView
extends Control

## Displays the hero party idle in the dungeon, with a background.
## Mirrors the battle scene layout so heroes appear in the same position.

var _hero_slots: Array = []  # UnitSlotUI instances
var _heroes: Array = []      # UnitData resources


func setup(heroes: Array) -> void:
	_heroes = heroes
	_build_ui()


func _build_ui() -> void:
	for child: Node in get_children():
		child.queue_free()

	# Background — same as battle scene
	var bg := TextureRect.new()
	bg.name = "Background"
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS

	if ResourceLoader.exists("res://assets/tiles/cave_dungeon_bg.png"):
		bg.texture = load("res://assets/tiles/cave_dungeon_bg.png")

	add_child(bg)

	# Match battle scene layout: VBox with spacer pushing formation to bottom
	var screen := VBoxContainer.new()
	screen.name = "Screen"
	screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	screen.add_theme_constant_override("separation", 0)
	add_child(screen)

	var spacer := Control.new()
	spacer.name = "Spacer"
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	screen.add_child(spacer)

	# Formation margin — same values as battle scene
	var formation_margin := MarginContainer.new()
	formation_margin.name = "FormationMargin"
	formation_margin.add_theme_constant_override("margin_left", 40)
	formation_margin.add_theme_constant_override("margin_right", 40)
	formation_margin.add_theme_constant_override("margin_top", 0)
	formation_margin.add_theme_constant_override("margin_bottom", 140)
	screen.add_child(formation_margin)

	var formation_area := HBoxContainer.new()
	formation_area.name = "FormationArea"
	formation_area.alignment = BoxContainer.ALIGNMENT_CENTER
	formation_area.add_theme_constant_override("separation", 0)
	formation_margin.add_child(formation_area)

	# Hero row — same spacing as battle scene
	var hero_row := HBoxContainer.new()
	hero_row.name = "HeroRow"
	hero_row.add_theme_constant_override("separation", 0)
	formation_area.add_child(hero_row)

	var slot_scene: PackedScene = load("res://scenes/ui/unit_slot.tscn")
	_hero_slots.clear()

	for hero_data: Resource in _heroes:
		var slot: Control = slot_scene.instantiate()
		hero_row.add_child(slot)
		_hero_slots.append(slot)

		var info := _hero_display_info(hero_data)
		slot.setup(info)

	# Fill the rest of the row to match battle layout (mid spacer + monster row width)
	# This keeps heroes in the same left-side position as during battle
	var right_spacer := Control.new()
	right_spacer.name = "RightSpacer"
	right_spacer.custom_minimum_size = Vector2(80 + 210 * 4, 0)
	formation_area.add_child(right_spacer)


func update_hero_hp(hero_index: int, current_hp: int, max_hp: int) -> void:
	if hero_index >= 0 and hero_index < _hero_slots.size():
		_hero_slots[hero_index].update_hp(current_hp, max_hp)


func _hero_display_info(hero_data: Resource) -> Dictionary:
	var unit_class: Resource = hero_data.get("unit_class")
	var stats := StatCalculator.compute_hero_stats(hero_data)

	return {
		"unit_id": hero_data.get("id"),
		"display_name": hero_data.get("display_name"),
		"side": "hero",
		"row": unit_class.get("preferred_row"),
		"slot": 0,
		"max_hp": stats.max_hp,
		"current_hp": stats.max_hp,
		"sprite_path": unit_class.get("sprite_path"),
	}
