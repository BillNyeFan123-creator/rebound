extends CanvasLayer

@onready var health_bar: ProgressBar = $HealthBar


func _ready() -> void:
	# The Player and WaveManager enter the tree after this HUD, so set up
	# connections on the next frame.
	_setup.call_deferred()


func _setup() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		push_error("HealthHUD could not find a node in the 'player' group")
		return
	health_bar.max_value = player.max_health
	health_bar.value = player.health
	if not player.health_changed.is_connected(_on_health_changed):
		player.health_changed.connect(_on_health_changed)

	# Run/wave readout; the WaveManager emits wave changes.
	var waves = get_tree().get_first_node_in_group("wave_manager")
	if waves and waves.has_signal("wave_started"):
		if not waves.wave_started.is_connected(_on_wave_started):
			waves.wave_started.connect(_on_wave_started)
	_update_run_label(0)


func _on_health_changed(current: int, maximum: int) -> void:
	health_bar.max_value = maximum
	health_bar.value = current


func _on_wave_started(wave: int) -> void:
	_update_run_label(wave)


func _update_run_label(wave: int) -> void:
	$RunLabel.text = "RUN %d  -  WAVE %d" % [RunState.run_count, wave]
