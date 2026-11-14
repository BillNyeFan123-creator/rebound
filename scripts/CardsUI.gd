extends CanvasLayer
# Card management overlay: a "Cards" button on the level that opens a panel
# with 3 equip slots and a scrollable list of unlocked (draggable) cards.

const CardSlotScript := preload("res://scripts/cardSystem/ui/CardSlot.gd")
const CardDraggableScript := preload("res://scripts/cardSystem/ui/CardDraggable.gd")
const CardPreviewScript := preload("res://scripts/cardSystem/ui/CardPreview.gd")

var preview: PanelContainer

@onready var panel: PanelContainer = $Panel
@onready var slots_box: HBoxContainer = $Panel/VBox/Slots
@onready var card_list: VBoxContainer = $Panel/VBox/CardListScroll/CardList


func _ready() -> void:
	# Keep working while the tree is paused (the menu pauses the game).
	process_mode = Node.PROCESS_MODE_ALWAYS
	preview = CardPreviewScript.new()
	add_child(preview)
	$OpenButton.pressed.connect(_on_open_pressed)
	$Panel/VBox/CloseButton.pressed.connect(_on_close_pressed)
	CardManager.loadout_changed.connect(refresh)
	refresh()


func _on_open_pressed() -> void:
	panel.visible = not panel.visible
	get_tree().paused = panel.visible
	refresh()


func _on_close_pressed() -> void:
	panel.visible = false
	get_tree().paused = false


func refresh() -> void:
	_refresh_slots()
	_refresh_card_list()


func _refresh_slots() -> void:
	for child in slots_box.get_children():
		child.queue_free()

	var equipped := CardManager.equipped
	for i in 3:
		var slot: PanelContainer = CardSlotScript.new()
		slot.slot_index = i
		slot.custom_minimum_size = Vector2(110, 40)
		slots_box.add_child(slot)

		var label := Label.new()
		label.text = equipped[i].card_name if i < equipped.size() else "(empty - drop a card)"
		slot.add_child(label)


func _refresh_card_list() -> void:
	for child in card_list.get_children():
		child.queue_free()

	for card in CardManager.unlocked:
		var button: Button = CardDraggableScript.new()
		button.card = card
		button.text = card.card_name
		button.disabled = CardManager.equipped.has(card)
		button.mouse_entered.connect(_on_card_hovered.bind(button))
		button.mouse_exited.connect(preview.hide)
		card_list.add_child(button)


func _on_card_hovered(button: Button) -> void:
	preview.show_card(button.card, button.global_position)
