class_name DamagePopup
extends Node2D

## Floating damage number that jumps up and fades out.
## Spawned by UnitSlotUI when damage/heal occurs.

const RISE_DISTANCE := 60.0
const RISE_DURATION := 0.8
const FADE_START := 0.4

var _label: Label


func _init() -> void:
	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override("font_size", 22)
	add_child(_label)


func setup_damage(amount: int, is_crit: bool) -> void:
	_label.text = str(amount)

	if is_crit:
		_label.text = str(amount) + "!"
		_label.add_theme_font_size_override("font_size", 30)
		_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.1))
	else:
		_label.add_theme_color_override("font_color", Color(1.0, 0.25, 0.2))

	_animate()


func setup_heal(amount: int) -> void:
	_label.text = "+" + str(amount)
	_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.3))

	_animate()


func setup_dodge() -> void:
	_label.text = "DODGE"
	_label.add_theme_font_size_override("font_size", 18)
	_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))

	_animate()


func _animate() -> void:
	# Center the label on spawn position
	_label.position = Vector2(-_label.size.x / 2.0, -_label.size.y)

	# Random horizontal offset for visual variety
	var h_offset := randf_range(-20.0, 20.0)

	var tween := create_tween()
	tween.set_parallel(true)

	# Jump up with slight horizontal drift
	tween.tween_property(self, "position:y", position.y - RISE_DISTANCE, RISE_DURATION) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tween.tween_property(self, "position:x", position.x + h_offset, RISE_DURATION)

	# Fade out in the second half
	tween.tween_property(self, "modulate:a", 0.0, RISE_DURATION - FADE_START) \
		.set_delay(FADE_START)

	# Scale pop for crits
	if _label.get_theme_font_size("font_size") > 22:
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15) \
			.from(Vector2(1.4, 1.4)).set_ease(Tween.EASE_OUT)

	tween.chain().tween_callback(queue_free)
