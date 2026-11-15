extends CanvasLayer

@onready var health_bar: ProgressBar = $HealthBar

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		push_error("HealthHUD could not find a node in the 'player' group")
		return
	# Run/wave readout; the WaveManager emits wave changes.
	var waves = get_tree().get_first_node_in_group("wave_manager")
	if waves and waves.has_signal("wave_started"):
		waves.wave_started.connect(_on_wave_started)
	# Defer in case the HUD ready-order runs before the WaveManager registers.
	_connect_waves.call_deferred()
	_update_run_label(0)


func _connect_waves() -> void:
	var waves = get_tree().get_first_node_in_group("wave_manager")
	if waves and waves.has_signal("wave_started") and not waves.wave_started.is_connected(_on_wave_started):
		waves.wave_started.connect(_on_wave_started)

	health_bar.max_value = player.max_health
	health_bar.value = player.health
	player.health_changed.connect(_on_health_changed)


func _on_health_changed(current: int, maximum: int) -> void:
	health_bar.max_value = maximum
	health_bar.value = current


func _on_wave_started(wave: int) -> void:
	_update_run_label(wave)


func _update_run_label(wave: int) -> void:
	$RunLabel.text = "RUN %d  -  WAVE %d" % [RunState.run_count, wave]
