extends CanvasLayer
# Shows the controls before the game starts. Pauses the game until OK is pressed.

@onready var root: Control = $Root


func _ready() -> void:
	$Root/Center/Panel/Box/OKButton.pressed.connect(_on_ok_pressed)
	# Toggling the node off in the editor disables the tutorial entirely
	# (no pause, no overlay).
	if not visible:
		root.visible = false
		return
	root.visible = true
	get_tree().paused = true


func _on_ok_pressed() -> void:
	root.visible = false
	get_tree().paused = false
