class_name GameCamera
extends Camera2D
# Player-follow camera with decaying screen shake.

var _shake_amount := 0.0


func _ready() -> void:
	add_to_group("camera")
	zoom = Vector2(2.0, 2.0)
	position_smoothing_enabled = true
	position_smoothing_speed = 6.0
	# Never show outside the arena.
	limit_left = 0
	limit_top = 0
	limit_right = 2304
	limit_bottom = 1296


func shake(amount: float) -> void:
	_shake_amount = maxf(_shake_amount, amount)


func _process(delta: float) -> void:
	if _shake_amount > 0.0:
		offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _shake_amount
		_shake_amount = move_toward(_shake_amount, 0.0, 24.0 * delta)
	else:
		offset = Vector2.ZERO
