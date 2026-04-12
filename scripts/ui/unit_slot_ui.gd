class_name UnitSlotUI
extends PanelContainer

## Displays one unit in the formation.
## Shows sprite + HP bar. Dead units get a red cross overlay.

@onready var _sprite: TextureRect = %Sprite
@onready var _dead_sprite: TextureRect = %DeadSprite
@onready var _hp_bar: ProgressBar = %HpBar
@onready var _hp_label: Label = %HpLabel
@onready var _vbox: VBoxContainer = $VBox

var _name_label: Label
var _unit_info: Dictionary = {}
var _is_occupied: bool = false
var _flash_tween: Tween


func _ready() -> void:
	_name_label = Label.new()
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.add_theme_font_size_override("font_size", 13)
	_name_label.add_theme_color_override("font_color", Color.WHITE)
	_name_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	_name_label.add_theme_constant_override("shadow_offset_x", 1)
	_name_label.add_theme_constant_override("shadow_offset_y", 1)
	_vbox.add_child(_name_label)
	_vbox.move_child(_name_label, 1)
	_vbox.add_theme_constant_override("separation", 4)

	# Style HP bar: red fill, black background
	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = Color(0.55, 0.05, 0.05)
	fill_style.set_corner_radius_all(2)
	_hp_bar.add_theme_stylebox_override("fill", fill_style)

	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color.BLACK
	bg_style.set_corner_radius_all(2)
	_hp_bar.add_theme_stylebox_override("background", bg_style)

	_show_empty()


func setup(info: Dictionary) -> void:
	_unit_info = info
	_is_occupied = true

	# Load sprite
	var path: String = info.get("sprite_path", "")

	if path != "" and ResourceLoader.exists(path):
		_sprite.texture = load(path)

	_sprite.visible = true
	_dead_sprite.visible = false
	_align_sprite_bottom()
	_name_label.text = info.get("display_name", "")
	_name_label.visible = true

	var max_hp: int = info.get("max_hp", 1)
	var current_hp: int = info.get("current_hp", max_hp)

	_hp_bar.max_value = max_hp
	_hp_bar.value = current_hp
	_hp_bar.visible = true
	_hp_label.text = "%d/%d" % [current_hp, max_hp]
	_hp_label.visible = true

	modulate = Color.WHITE


func update_hp(current: int, max_val: int) -> void:
	_hp_bar.max_value = max_val
	_hp_bar.value = current
	_hp_label.text = "%d/%d" % [current, max_val]


func update_info(info: Dictionary) -> void:
	_unit_info = info
	update_hp(info.get("current_hp", 0), info.get("max_hp", 1))


func flash_damage() -> void:
	_flash(Color(1.0, 0.3, 0.3))
	_show_slash()


func flash_heal() -> void:
	_flash(Color(0.3, 1.0, 0.3))


func show_damage_number(amount: int, is_crit: bool) -> void:
	var popup := DamagePopup.new()
	popup.position = Vector2(size.x / 2.0, size.y * 0.3)
	_sprite.add_child(popup)
	popup.setup_damage(amount, is_crit)


func show_heal_number(amount: int) -> void:
	var popup := DamagePopup.new()
	popup.position = Vector2(size.x / 2.0, size.y * 0.3)
	_sprite.add_child(popup)
	popup.setup_heal(amount)


func show_dodge() -> void:
	var popup := DamagePopup.new()
	popup.position = Vector2(size.x / 2.0, size.y * 0.3)
	_sprite.add_child(popup)
	popup.setup_dodge()


func _show_slash() -> void:
	var slash := SlashEffect.new()
	slash.set_anchors_preset(Control.PRESET_FULL_RECT)
	_sprite.add_child(slash)
	slash.play()


func mark_dead() -> void:
	_sprite.visible = false
	_hp_bar.visible = false
	_hp_label.visible = false
	_name_label.visible = false
	_dead_sprite.visible = true
	modulate = Color.WHITE


func mark_alive() -> void:
	_sprite.visible = true
	_dead_sprite.visible = false
	_name_label.visible = true
	_hp_bar.visible = true
	_hp_label.visible = true
	modulate = Color.WHITE


func clear() -> void:
	_show_empty()


func get_unit_id() -> String:
	return _unit_info.get("unit_id", "")


func _align_sprite_bottom() -> void:
	if _sprite.texture == null:
		return

	var tex_size := _sprite.texture.get_size()
	var container_w := 210.0
	var container_h := 270.0
	var scale := minf(container_w / tex_size.x, container_h / tex_size.y)
	var rendered_w := tex_size.x * scale
	var rendered_h := tex_size.y * scale

	# Position sprite at bottom-center of container
	_sprite.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_sprite.position = Vector2((container_w - rendered_w) / 2.0, container_h - rendered_h)
	_sprite.size = Vector2(rendered_w, rendered_h)


func _show_empty() -> void:
	_is_occupied = false
	_sprite.texture = null
	_sprite.visible = false
	_dead_sprite.visible = false
	_hp_bar.visible = false
	_hp_label.text = ""

	if _name_label:
		_name_label.text = ""
		_name_label.visible = false

	modulate = Color(1, 1, 1, 0.3)


func _flash(flash_color: Color) -> void:
	if _flash_tween != null:
		_flash_tween.kill()

	_flash_tween = create_tween()
	_flash_tween.tween_property(self, "modulate", flash_color, 0.1)
	_flash_tween.tween_property(self, "modulate", Color.WHITE, 0.3)
