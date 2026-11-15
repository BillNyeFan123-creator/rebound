class_name GameCamera
extends Camera2D
# Player-follow camera with decaying screen shake and a subtle zoom "punch"
# on impacts.

const BASE_ZOOM := 1.5
const LOW_HP_ZOOM := 1.65
const LOW_HP_THRESHOLD := 0.3

var _shake_amount := 0.0
var _zoom_kick := 0.0
var _current_base := BASE_ZOOM


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

	# Tension zoom: pull closer while badly hurt.
	var target := BASE_ZOOM
	var player := get_parent()
	if player and "health" in player and player.health <= player.max_health * LOW_HP_THRESHOLD:
		target = LOW_HP_ZOOM
	_current_base = move_toward(_current_base, target, 0.4 * delta)

	if _zoom_kick > 0.0:
		_zoom_kick = move_toward(_zoom_kick, 0.0, 0.4 * delta)
	zoom = Vector2.ONE * (_current_base + _zoom_kick)
