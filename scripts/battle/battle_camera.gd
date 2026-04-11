class_name BattleCamera
extends Camera2D

const ZOOM_MIN: float = 0.5
const ZOOM_MAX: float = 3.0
const ZOOM_STEP: float = 0.1
const PAN_SPEED: float = 1.0

var _is_panning: bool = false
var _pan_start: Vector2


func _ready() -> void:
	zoom = Vector2(1.5, 1.5)


func _unhandled_input(event: InputEvent) -> void:
	# Zoom with scroll wheel
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_apply_zoom(ZOOM_STEP)
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_apply_zoom(-ZOOM_STEP)
			get_viewport().set_input_as_handled()

		# Pan start/stop with right click
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_is_panning = event.pressed

			if event.pressed:
				_pan_start = event.position

			get_viewport().set_input_as_handled()

	# Pan with right-click drag
	if event is InputEventMouseMotion and _is_panning:
		var motion := event as InputEventMouseMotion
		var delta: Vector2 = (_pan_start - motion.position) * PAN_SPEED / zoom.x
		position += delta
		_pan_start = motion.position
		get_viewport().set_input_as_handled()


func _apply_zoom(step: float) -> void:
	var new_zoom := clampf(zoom.x + step, ZOOM_MIN, ZOOM_MAX)
	zoom = Vector2(new_zoom, new_zoom)
