extends AnimatedSprite2D
# Drives the knight's animations from the player's state:
# idle <-> walk (matching left/right art), one-shot attack swings, and a
# squash-stretch dash pose (no dedicated dash art yet).

const ANIM_IDLE := "knight idle"
const ANIM_WALK_LEFT := "knight walk left"
const ANIM_WALK_RIGHT := "knight walk right"
const ANIM_ATTACK_LEFT := "knight attack left"
const ANIM_ATTACK_RIGHT := "knight attack right"
const ANIM_ATTACK_FRONT := "knight attack front"

const DASH_STRETCH_X := 1.35
const DASH_SQUASH_Y := 0.8

var _base_scale := Vector2.ONE
var _attacking := false


func _ready() -> void:
	_base_scale = scale
	play(ANIM_IDLE)
	var player := get_parent()
	if player and player.has_signal("attack_started"):
		player.attack_started.connect(_on_attack_started)


func _on_attack_started() -> void:
	var player := get_parent()
	_attacking = true
	scale = _base_scale
	# Standing still? Swing toward the camera; moving? swing in travel direction.
	if player and absf(player.velocity.x) > 10.0:
		if player.facing >= 0.0:
			play(ANIM_ATTACK_RIGHT)
		else:
			play(ANIM_ATTACK_LEFT)
	elif sprite_frames.has_animation("knight attack front"):
		play("knight attack front")
	elif player and player.facing >= 0.0:
		play(ANIM_ATTACK_RIGHT)
	else:
		play(ANIM_ATTACK_LEFT)


func _physics_process(_delta: float) -> void:
	var player := get_parent() as CharacterBody2D
	if player == null:
		return

	# Attack swing overrides everything until the animation finishes.
	if _attacking:
		if is_playing() and animation in [ANIM_ATTACK_LEFT, ANIM_ATTACK_RIGHT, ANIM_ATTACK_FRONT]:
			return
		_attacking = false

	if player.dash_time > 0.0:
		# Dash pose: stretch along the dash direction.
		play(ANIM_WALK_RIGHT if player.dash_dir.x >= 0.0 else ANIM_WALK_LEFT)
		var stretch := signf(player.dash_dir.x)
		if is_zero_approx(stretch):
			stretch = 1.0
		scale = Vector2(
			_base_scale.x * (DASH_STRETCH_X if stretch > 0.0 else DASH_SQUASH_Y),
			_base_scale.y * (DASH_SQUASH_Y if stretch > 0.0 else DASH_STRETCH_X)
		)
		return

	scale = _base_scale
	if absf(player.velocity.x) > 10.0:
		var walk := ANIM_WALK_RIGHT if player.velocity.x > 0.0 else ANIM_WALK_LEFT
		if animation != walk:
			play(walk)
	else:
		if animation != ANIM_IDLE:
			play(ANIM_IDLE)
