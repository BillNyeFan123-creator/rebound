class_name Enemy
extends CharacterBody2D

signal died

const HitStopScript = preload("res://scripts/arena/HitStop.gd")

@export var max_health := 3
@export var speed := 50.0
@export var contact_damage := 15

var health: int = max_health

@onready var anim: AnimatedSprite2D = get_node_or_null("Anim")


func _ready() -> void:
	if anim and anim.sprite_frames.has_animation("idle"):
		anim.play("idle")
		anim.animation_finished.connect(_on_anim_finished)


func _physics_process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		velocity.x = move_toward(velocity.x, 0.0, speed)
		velocity += get_gravity() * _delta
		move_and_slide()
		return

	# Chase horizontally, respect gravity, and hop when blocked.
	var direction := signf(player.global_position.x - global_position.x)
	if absf(player.global_position.x - global_position.x) < 6.0:
		direction = 0.0
	velocity.x = direction * speed
	velocity += get_gravity() * _delta
	if is_on_floor() and is_on_wall() and direction != 0.0:
		velocity.y = -350.0  # hop over obstacles
	move_and_slide()

	if anim and _can_play_move_anim():
		if absf(velocity.x) > 5.0 and anim.sprite_frames.has_animation("jump"):
			if anim.animation != "jump":
				anim.play("jump")
		elif anim.sprite_frames.has_animation("idle") and anim.animation != "idle":
			anim.play("idle")

	# Contact damage. The player's i-frames prevent this from stacking every frame.
	for body in $Hurtbox.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(contact_damage)


func _can_play_move_anim() -> bool:
	return not anim.is_playing() \
		or anim.animation in ["idle", "jump"]


func _on_anim_finished() -> void:
	if anim.animation == "get_hit":
		anim.play("idle") if absf(velocity.x) <= 5.0 else anim.play("jump")


func take_hit(damage: float) -> void:
	health -= int(ceil(damage))
	if health <= 0:
		die()
		return
	if anim and anim.sprite_frames.has_animation("get_hit"):
		anim.play("get_hit")


func die() -> void:
	HitStopScript.trigger()  # brief freeze on the killing blow
	var cam = get_tree().get_first_node_in_group("camera")
	if cam:
		cam.shake(3.0)
	Sfx.play("kill", -4.0)
	died.emit()
	# Play the death animation, then remove the body.
	if anim and anim.sprite_frames.has_animation("death"):
		collision_layer = 0
		collision_mask = 0
		$Hurtbox.monitoring = false
		anim.play("death")
		await anim.animation_finished
	queue_free()
