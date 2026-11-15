class_name GameCamera
extends Camera2D
# Player-follow camera with decaying screen shake and a subtle zoom "punch"
# on impacts.

const BASE_ZOOM := 1.5

var _shake_amount := 0.0
var _zoom_kick := 0.0


func _ready() -> void:
	add_to_group("camera")
	zoom = Vector2(BASE_ZOOM, BASE_ZOOM)
	position_smoothing_enabled = true
	position_smoothing_speed = 6.0
	# Never show outside the arena.
	limit_left = 0
	limit_top = 0
	limit_right = 1728
	limit_bottom = 972


func shake(amount: float) -> void:
	_shake_amount = maxf(_shake_amount, amount)
	_zoom_kick = maxf(_zoom_kick, amount * 0.012)


func _process(delta: float) -> void:
	if _shake_amount > 0.0:
		offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _shake_amount
		_shake_amount = move_toward(_shake_amount, 0.0, 24.0 * delta)
	else:
		offset = Vector2.ZERO

	if _zoom_kick > 0.0:
		_zoom_kick = move_toward(_zoom_kick, 0.0, 0.4 * delta)
		zoom = Vector2.ONE * (BASE_ZOOM + _zoom_kick)
