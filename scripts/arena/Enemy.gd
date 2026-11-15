class_name Enemy
extends CharacterBody2D

signal died

const HitStopScript = preload("res://scripts/arena/HitStop.gd")

@export var max_health := 2
@export var speed := 60.0
@export var contact_damage := 10

var health: int = max_health


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

	# Contact damage. The player's i-frames prevent this from stacking every frame.
	for body in $Hurtbox.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(contact_damage)


func take_hit(damage: float) -> void:
	health -= int(ceil(damage))
	if health <= 0:
		die()
		return
	# Hit flash.
	var tween := create_tween()
	modulate = Color(3, 3, 3)
	tween.tween_property(self, "modulate", Color.WHITE, 0.15)


func die() -> void:
	HitStopScript.trigger()  # brief freeze on the killing blow
	var cam = get_tree().get_first_node_in_group("camera")
	if cam:
		cam.shake(3.0)
	died.emit()
	queue_free()
