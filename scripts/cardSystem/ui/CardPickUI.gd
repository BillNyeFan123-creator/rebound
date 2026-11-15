extends CanvasLayer
# Shown by the WaveManager when the player dies: pick 1 of 3 cards to bounce back with.
# Process mode is ALWAYS so it keeps working while the tree is paused.

signal card_chosen(card: Card)

const OFFER_COUNT := 3
const CardPreviewScript := preload("res://scripts/cardSystem/ui/CardPreview.gd")

var preview: PanelContainer

@onready var root: Control = $Root
@onready var buttons_box: VBoxContainer = $Root/Center/Box


func _ready() -> void:
	preview = CardPreviewScript.new()
	add_child(preview)


func open() -> void:
	for child in buttons_box.get_children():
		child.queue_free()

	var pool := CardManager.unlocked.filter(
		func(c: Card): return not CardManager.equipped.has(c)
	)
	# Dedupe by card type so the same card can never appear twice.
	var seen: Array = []
	var unique: Array[Card] = []
	for c in pool:
		if not seen.has(c.get_script()):
			seen.append(c.get_script())
			unique.append(c)
	pool = unique
	pool.shuffle()
	for card in pool.slice(0, OFFER_COUNT):
		var button := Button.new()
		button.text = card.card_name
		button.pressed.connect(_on_card_pressed.bind(card))
		button.mouse_entered.connect(_on_card_hovered.bind(card, button))
		button.mouse_exited.connect(preview.hide)
		buttons_box.add_child(button)

	root.visible = true


func _on_card_hovered(card: Card, button: Button) -> void:
	preview.show_card(card, button.global_position)


func close() -> void:
	root.visible = false


func _on_card_pressed(card: Card) -> void:
	# One-shot guard: a double-click must not fire the choice twice.
	if not root.visible:
		return
	close()
	card_chosen.emit(card)
