extends PanelContainer
# One of the 3 equip slots. Drop a card here to equip it; drag the equipped
# card out (into the list, another slot, anywhere) to unequip it.

var slot_index := 0


func _get_drag_data(_at_position: Vector2) -> Variant:
	if slot_index >= CardManager.equipped.size():
		return null
	var card: Card = CardManager.equipped[slot_index]
	set_drag_preview(_make_preview(card))
	return card


func _make_preview(card: Card) -> Control:
	var wrapper := PanelContainer.new()
	var label := Label.new()
	label.text = card.card_name
	wrapper.add_child(label)
	return wrapper


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if not data is Card:
		return false
	if CardManager.equipped.has(data):
		return true  # dropping an equipped card here unequips it
	return CardManager.unlocked.has(data) and CardManager.equipped.size() < 3


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if CardManager.equipped.has(data):
		CardManager.remove(data)
	else:
		CardManager.equip(data)
