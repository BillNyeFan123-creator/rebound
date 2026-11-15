extends AnimatedSprite2D
# Drives the knight's animations from the player's state:
# idle <-> walk (uses the matching left/right art), plus a squash-stretch
# dash pose since there is no dedicated dash art yet.

const ANIM_IDLE := "knight idle"
const ANIM_WALK_LEFT := "knight walk left"
const ANIM_WALK_RIGHT := "knight walk right"

const DASH_STRETCH_X := 1.35
const DASH_SQUASH_Y := 0.8

var _base_scale := Vector2.ONE


func _ready() -> void:
	_base_scale = scale
	play(ANIM_IDLE)


func _physics_process(_delta: float) -> void:
	var player := get_parent() as CharacterBody2D
	if player == null:
		return

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
