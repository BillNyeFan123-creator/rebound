extends PanelContainer
# Floating card preview: shows a card's name and description while hovering.
# Position it with show_card(), hide it with hide().

var title_label: Label
var desc_label: Label


func _init() -> void:
	custom_minimum_size = Vector2(220, 0)
	visible = false
	z_index = 10
	# Let clicks and hover pass through to the card underneath.
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var box := VBoxContainer.new()
	add_child(box)

	title_label = Label.new()
	title_label.text = "Card"
	box.add_child(title_label)

	desc_label = Label.new()
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.custom_minimum_size = Vector2(200, 0)
	box.add_child(desc_label)


func show_card(card: Card, anchor: Vector2) -> void:
	title_label.text = card.card_name
	desc_label.text = card.description if card.description != "" else "No description yet."
	visible = true
	global_position = anchor + Vector2(24, -8)
	_clamp_to_viewport()


func _clamp_to_viewport() -> void:
	# Wait a frame so size reflects the new text, then keep it on screen.
	await get_tree().process_frame
	var view := get_viewport_rect().size
	global_position.x = clampf(global_position.x, 0.0, maxf(0.0, view.x - size.x))
	global_position.y = clampf(global_position.y, 0.0, maxf(0.0, view.y - size.y))
