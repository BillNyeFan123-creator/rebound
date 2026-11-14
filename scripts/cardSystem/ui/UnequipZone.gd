extends VBoxContainer
# Drop zone under the card list: dropping an equipped card here unequips it.


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Card and CardManager.equipped.has(data)


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	CardManager.remove(data)
