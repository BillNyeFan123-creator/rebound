extends AnimatedSprite2D
# Knight animation controller. A small state machine:
#   IDLE <-> WALK <-> DASH, with ATTACK as a one-shot override.
# The controller owns the sprite entirely; gameplay code only emits
# `attack_started` and sets dash/velocity fields on the player.

enum State { IDLE, WALK, ATTACK, DASH }

const ANIM_IDLE := "knight idle"
const ANIM_WALK_LEFT := "knight walk left"
const ANIM_WALK_RIGHT := "knight walk right"
const ANIM_ATTACK_LEFT := "knight attack left"
const ANIM_ATTACK_RIGHT := "knight attack right"
const ANIM_ATTACK_FRONT := "knight attack front"

const MOVE_SPEED_THRESHOLD := 10.0
const DASH_STRETCH_X := 1.35
const DASH_SQUASH_Y := 0.8

var base_scale := Vector2.ONE
var _state: int = State.IDLE
var _attack_requested := false


func _ready() -> void:
	base_scale = scale
	_play_for_state()
	var player := get_parent()
	if player and player.has_signal("attack_started"):
		player.attack_started.connect(_on_attack_started)


func _on_attack_started() -> void:
	_attack_requested = true


func _physics_process(_delta: float) -> void:
	var player := get_parent() as CharacterBody2D
	if player == null:
		return

	# While the death fizzle or spawn ghost tween owns the sprite
	# (modulate alpha != 1), the controller stands down.
	if modulate.a < 0.99:
		return
	# Dead players are being fizzled out; don't fight the tween.
	if player.health <= 0:
		return

	var next := _decide_state(player)
	if next != _state:
		_state = next
		_play_for_state()

	# The dash pose is a live transform, applied every dash frame.
	if _state == State.DASH:
		_apply_dash_pose(player)
	elif _state != State.ATTACK:
		scale = base_scale


func _decide_state(player: CharacterBody2D) -> int:
	# Attacks win: consume the request, play the swing, hold until it ends.
	if _attack_requested:
		if _state != State.ATTACK:
			_state = State.ATTACK
			_play_for_state()
			return _state
		if is_playing():
			return _state
		_attack_requested = false  # swing finished
	if player.dash_time > 0.0:
		return State.DASH
	if absf(player.velocity.x) > MOVE_SPEED_THRESHOLD:
		return State.WALK
	return State.IDLE


func _play_for_state() -> void:
	var player := get_parent()
	match _state:
		State.ATTACK:
			play(_pick_attack_anim(player))
		State.DASH:
			_apply_dash_pose(player)
		State.WALK:
			if player and player.velocity.x > 0.0:
				play(ANIM_WALK_RIGHT)
			else:
				play(ANIM_WALK_LEFT)
			scale = base_scale
		_:
			play(ANIM_IDLE)
			scale = base_scale


func _pick_attack_anim(player) -> String:
	# Standing still: swing toward the camera. Moving: swing along travel.
	if player and absf(player.velocity.x) > MOVE_SPEED_THRESHOLD:
		return ANIM_ATTACK_RIGHT if player.facing >= 0.0 else ANIM_ATTACK_LEFT
	if sprite_frames.has_animation(ANIM_ATTACK_FRONT):
		return ANIM_ATTACK_FRONT
	return ANIM_ATTACK_RIGHT if player.facing >= 0.0 else ANIM_ATTACK_LEFT


func _apply_dash_pose(player: CharacterBody2D) -> void:
	var dir := signf(player.dash_dir.x)
	if is_zero_approx(dir):
		dir = 1.0
	play(ANIM_WALK_RIGHT if dir > 0.0 else ANIM_WALK_LEFT)
	scale = Vector2(
		base_scale.x * (DASH_STRETCH_X if dir > 0.0 else DASH_SQUASH_Y),
		base_scale.y * (DASH_SQUASH_Y if dir > 0.0 else DASH_STRETCH_X)
	)
