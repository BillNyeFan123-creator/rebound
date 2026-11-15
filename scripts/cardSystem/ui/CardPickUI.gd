extends CanvasLayer
# Shown by the WaveManager when the player dies: pick 1 of 3 cards to bounce back with.
# Each card is a clickable panel showing its name and description side by side.
# Process mode is ALWAYS so it keeps working while the tree is paused.

signal card_chosen(card: Card)

const OFFER_COUNT := 3

@onready var root: Control = $Root
@onready var cards_box: HBoxContainer = $Root/Center/Panel/VBox/Cards


func open() -> void:
	for child in cards_box.get_children():
		child.queue_free()

	var pool := CardManager.unlockable_cards()
	pool.shuffle()
	for card in pool.slice(0, OFFER_COUNT):
		cards_box.add_child(_build_card_panel(card))

	root.visible = true


func _build_card_panel(card: Card) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(230, 210)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	panel.add_child(box)

	var name_label := Label.new()
	name_label.text = card.card_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 26)
	box.add_child(name_label)

	var desc_label := Label.new()
	desc_label.text = card.description if card.description != "" else "No description yet."
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	desc_label.custom_minimum_size = Vector2(0, 110)
	box.add_child(desc_label)

	# The whole panel is the click target.
	panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	panel.mouse_entered.connect(func(): panel.modulate = Color(1.12, 1.12, 1.12))
	panel.mouse_exited.connect(func(): panel.modulate = Color.WHITE)
	panel.gui_input.connect(_on_card_gui_input.bind(card, panel))
	return panel


func _on_card_gui_input(event: InputEvent, card: Card, panel: PanelContainer) -> void:
	if event is InputEventMouseButton \
			and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		_choose(card)


func _choose(card: Card) -> void:
	Sfx.play("card_pick", -2.0)
	root.visible = false
	card_chosen.emit(card)


func close() -> void:
	root.visible = false
