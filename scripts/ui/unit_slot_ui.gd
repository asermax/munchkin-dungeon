class_name UnitSlotUI
extends PanelContainer

## Displays one unit in the formation.
## Shows sprite + HP bar. Dead units get a red cross overlay.

@onready var _sprite: TextureRect = %Sprite
@onready var _dead_sprite: TextureRect = %DeadSprite
@onready var _hp_bar: ProgressBar = %HpBar
@onready var _hp_label: Label = %HpLabel

var _unit_info: Dictionary = {}
var _is_occupied: bool = false
var _flash_tween: Tween


func _ready() -> void:
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
	_dead_sprite.visible = true
	modulate = Color.WHITE


func mark_alive() -> void:
	_sprite.visible = true
	_dead_sprite.visible = false
	_hp_bar.visible = true
	_hp_label.visible = true
	modulate = Color.WHITE


func clear() -> void:
	_show_empty()


func get_unit_id() -> String:
	return _unit_info.get("unit_id", "")


func _show_empty() -> void:
	_is_occupied = false
	_sprite.texture = null
	_sprite.visible = false
	_dead_sprite.visible = false
	_hp_bar.visible = false
	_hp_label.text = ""
	modulate = Color(1, 1, 1, 0.3)


func _flash(flash_color: Color) -> void:
	if _flash_tween != null:
		_flash_tween.kill()

	_flash_tween = create_tween()
	_flash_tween.tween_property(self, "modulate", flash_color, 0.1)
	_flash_tween.tween_property(self, "modulate", Color.WHITE, 0.3)
