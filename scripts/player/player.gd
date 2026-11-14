extends CharacterBody2D

signal health_changed(current: int, maximum: int)
signal died

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const MAX_HEALTH = 100
const HAZARD_DAMAGE = 10
const INVULN_TIME = 0.5

var health: int = MAX_HEALTH
var invuln_timer := 0.0


func _ready() -> void:
	died.connect(_on_died)
	RunState.set_checkpoint(0, global_position)


func _physics_process(delta: float) -> void:
	if invuln_timer > 0.0:
		invuln_timer -= delta

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	check_hazards()

func check_hazards() -> void:
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		print("Hit: ", collider.name, " groups: ", collider.get_groups())
		if collider is Node and collider.is_in_group("obstacle"):
			take_damage(HAZARD_DAMAGE)
			return


func take_damage(amount: int) -> void:
	print("take_damage, health: ", health, " invuln: ", invuln_timer)
	if invuln_timer > 0.0 or health <= 0:
		return

	health = max(health - amount, 0)
	invuln_timer = INVULN_TIME
	health_changed.emit(health, MAX_HEALTH)

	if health == 0:
		died.emit()


func heal(amount: int) -> void:
	health = min(health + amount, MAX_HEALTH)
	health_changed.emit(health, MAX_HEALTH)


func reset_health() -> void:
	health = MAX_HEALTH
	invuln_timer = 0.0
	health_changed.emit(health, MAX_HEALTH)


func _on_died() -> void:
	# Respawn at the checkpoint instead of reloading the level.
	# Requires the RunState autoload with checkpoint_pos set.
	RunState.on_death()
	global_position = RunState.checkpoint_pos
	velocity = Vector2.ZERO
	reset_health()
