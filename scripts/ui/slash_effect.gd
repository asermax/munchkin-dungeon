class_name SlashEffect
extends TextureRect

## Slash animation overlay that flashes on a unit when they take damage.
## Spawned on top of the unit sprite, plays once and self-destructs.

const SLASH_DURATION := 0.35

static var _slash_texture: Texture2D


func _init() -> void:
	if _slash_texture == null and ResourceLoader.exists("res://assets/fx/slash.png"):
		_slash_texture = load("res://assets/fx/slash.png")

	texture = _slash_texture
	expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	modulate = Color(1, 1, 1, 0)

	# Random rotation for variety
	pivot_offset = size / 2.0
	rotation = randf_range(-0.3, 0.3)


func play() -> void:
	var tween := create_tween()

	# Flash in and scale up
	tween.tween_property(self, "modulate:a", 1.0, 0.05)
	tween.tween_property(self, "modulate:a", 0.0, SLASH_DURATION) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)

	tween.tween_callback(queue_free)
