extends Button
# A card in the unlocked list. Can be dragged onto a CardSlot to equip it.

var card: Card


func _get_drag_data(_at_position: Vector2) -> Variant:
	if card == null or CardManager.equipped.has(card):
		return null
	set_drag_preview(_make_preview())
	return card


func _make_preview() -> Control:
	var wrapper := PanelContainer.new()
	var label := Label.new()
	label.text = card.card_name
	wrapper.add_child(label)
	return wrapper
