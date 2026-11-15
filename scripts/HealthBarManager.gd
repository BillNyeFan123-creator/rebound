extends CanvasLayer

@onready var health_bar: ProgressBar = $HealthBar

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		push_error("HealthHUD could not find a node in the 'player' group")
		return

	health_bar.max_value = player.max_health
	health_bar.value = player.health
	player.health_changed.connect(_on_health_changed)


func _on_health_changed(current: int, maximum: int) -> void:
	health_bar.max_value = maximum
	health_bar.value = current
