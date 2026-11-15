extends CharacterBody2D

signal health_changed(current: int, maximum: int)
signal died
signal attack_started

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const BASE_MAX_HEALTH = 100
const HAZARD_DAMAGE = 10
const INVULN_TIME = 0.5
const ATTACK_COOLDOWN = 0.4
const ATTACK_DAMAGE = 1.0
const ATTACK_RADIUS = 60.0
const DASH_SPEED = 900.0
const DASH_TIME = 0.15
const DASH_COOLDOWN = 0.8
const JUMP_BUFFER_TIME = 0.12  # presses this long before landing still jump
const COYOTE_TIME = 0.12       # grace period to jump after leaving the ground

var health: int = BASE_MAX_HEALTH
var invuln_timer := 0.0
# Stats cards can modify (see CardLibrary.gd for what each does).
var max_health: int = BASE_MAX_HEALTH
var damage_mult := 1.0
var speed_mult := 1.0
var jump_mult := 1.0
var damage_taken_mult := 1.0
var heal_on_kill := 0.0
var attack_cd_mult := 1.0
var attack_radius_bonus := 0.0
var dash_cd_mult := 1.0
var dash_time_mult := 1.0
var low_hp_speed_mult := 1.0
var respawn_max_health_bonus := 0
var attack_cd := 0.0
var dash_cd := 0.0
var dash_time := 0.0
var dash_dir := Vector2.RIGHT
var facing := 1.0
var jump_buffer := 0.0
var coyote := 0.0


func _ready() -> void:
	RunState.set_checkpoint(0, global_position)


func _physics_process(delta: float) -> void:
	attack_cd -= delta
	dash_cd -= delta
	if invuln_timer > 0.0:
		invuln_timer -= delta

	# Dashing overrides normal movement for DASH_TIME seconds.
	if dash_time > 0.0:
		dash_time -= delta
		velocity = dash_dir * DASH_SPEED
		move_and_slide()
		check_hazards()
		return

	if is_on_floor():
		coyote = COYOTE_TIME
	else:
		coyote -= delta
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump"):
		jump_buffer = JUMP_BUFFER_TIME
	else:
		jump_buffer -= delta

	if jump_buffer > 0.0 and coyote > 0.0:
		velocity.y = JUMP_VELOCITY * jump_mult
		jump_buffer = 0.0
		coyote = 0.0
		Sfx.play("jump", -8.0)

	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED * _effective_speed_mult()
		facing = signf(direction)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * _effective_speed_mult())

	if Input.is_action_just_pressed("attack") and attack_cd <= 0.0:
		_do_attack()

	if Input.is_action_just_pressed("dash") and dash_cd <= 0.0:
		_start_dash(direction)

	move_and_slide()
	check_hazards()


func _effective_speed_mult() -> float:
	# Adrenaline-style cards: faster when badly hurt.
	var mult := speed_mult
	if health <= max_health * 0.3:
		mult *= low_hp_speed_mult
	return mult


func _do_attack() -> void:
	attack_cd = ATTACK_COOLDOWN * attack_cd_mult
	Sfx.play("attack", -8.0)
	attack_started.emit()
	$AttackArea/CollisionShape2D.shape.radius = ATTACK_RADIUS + attack_radius_bonus
	for body in $AttackArea.get_overlapping_bodies():
		if body.is_in_group("enemy"):
			body.take_hit(ATTACK_DAMAGE * damage_mult)


func _start_dash(direction: float) -> void:
	if direction != 0.0:
		dash_dir = Vector2(direction, 0.0)
	else:
		dash_dir = Vector2(facing, 0.0)
	Sfx.play("dash", -6.0)
	invuln_timer = maxf(invuln_timer, DASH_TIME * dash_time_mult)
	dash_time = DASH_TIME * dash_time_mult
	dash_cd = DASH_COOLDOWN * dash_cd_mult


func check_hazards() -> void:
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider is Node and collider.is_in_group("obstacle"):
			take_damage(HAZARD_DAMAGE)
			return


func take_damage(amount: int) -> void:
	if invuln_timer > 0.0 or health <= 0:
		return

	health = max(health - maxi(1, roundi(amount * damage_taken_mult)), 0)
	invuln_timer = INVULN_TIME
	health_changed.emit(health, max_health)
	_shake(5.0)
	Sfx.play("hurt", -4.0)

	if health == 0:
		died.emit()


func _shake(amount: float) -> void:
	var cam = get_tree().get_first_node_in_group("camera")
	if cam:
		cam.shake(amount)


func heal(amount: int) -> void:
	health = mini(health + amount, max_health)
	health_changed.emit(health, max_health)


func on_enemy_killed() -> void:
	# Lifesteal hook, called by the WaveManager when an enemy dies.
	if heal_on_kill > 0.0:
		heal(roundi(heal_on_kill))
	_shake(2.5)


func reset_health() -> void:
	health = max_health
	invuln_timer = 0.0
	health_changed.emit(health, max_health)


func respawn() -> void:
	# Called by the WaveManager after the player bounces back with a card.
	if respawn_max_health_bonus > 0:
		max_health += respawn_max_health_bonus
	RunState.on_death()
	Sfx.play("respawn", -4.0)

	var sprite = get_node_or_null("SpriteKnight")
	var base_scale := Vector2.ONE
	if sprite:
		if "_base_scale" in sprite:
			base_scale = sprite._base_scale
		# Ghost state: bright white silhouette, faded out, floating above.
		sprite.modulate = Color(2.4, 2.4, 2.4, 0.0)
		sprite.scale = Vector2(base_scale.x * 1.5, base_scale.y * 0.75)

	global_position = RunState.checkpoint_pos + Vector2(0, -140)
	velocity = Vector2.ZERO
	dash_time = 0.0
	reset_health()
	# Grace period: ceiling spawners can drop slimes right on the spawn point.
	invuln_timer = 1.5

	if sprite:
		# Drop in: fall with a bounce while the ghost fades into the knight.
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(self, "global_position:y", RunState.checkpoint_pos.y, 0.5) \
			.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tw.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.45)
		tw.tween_property(sprite, "scale", base_scale, 0.5) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
