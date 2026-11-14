class_name Card
extends Resource

@export var card_name: String = "Card"
@export_multiline var description: String = ""
@export var icon: Texture2D

# Each card type overrides this to do its effect
func apply(player: Node) -> void:
	pass
