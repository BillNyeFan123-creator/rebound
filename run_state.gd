extends Node

@export var min_survive_time := 20.0

var checkpoint_id := -1
var checkpoint_pos := Vector2.ZERO
var rewarded_checkpoint_id := -2
var time_since_respawn := 0.0
var deaths := 0
var run_count := 1  # attempt number; increments on every death

func _process(delta: float) -> void:
	time_since_respawn += delta

func set_checkpoint(id: int, pos: Vector2) -> void:
	checkpoint_id = id
	checkpoint_pos = pos

# Returns true if this death should grant a powerup pick
func on_death() -> bool:
	deaths += 1
	var earned := checkpoint_id != rewarded_checkpoint_id \
		and time_since_respawn >= min_survive_time
	if earned:
		rewarded_checkpoint_id = checkpoint_id
	time_since_respawn = 0.0
	return earned
