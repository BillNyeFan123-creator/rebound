extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	RunState.run_count = 1  # fresh session from the start screen
	get_tree().change_scene_to_file("res://Level.tscn")
