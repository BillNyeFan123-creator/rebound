class_name HitStop
# Brief time-freeze on big impacts (killing blows etc.). Uses time_scale so it
# never conflicts with pause-based UIs like the card pick screen.

static func trigger(duration := 0.09, slowdown := 0.05) -> void:
	if Engine.time_scale < 1.0:
		return  # already mid hit-stop
	Engine.time_scale = slowdown
	var tree := Engine.get_main_loop() as SceneTree
	tree.create_timer(duration, true, false, true).timeout.connect(
		func(): Engine.time_scale = 1.0
	)
