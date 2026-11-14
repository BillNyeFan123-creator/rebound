extends Node

signal loadout_changed

const STARTING_UNLOCK_COUNT := 0

var _library: Array[Card] = []

@export var unlocked: Array[Card]
@export var equipped: Array[Card]


# Seeds the starting card pool; the rest unlock as you play.
func _ready() -> void:
	_library = CardLibrary.get_all()
	_library.shuffle()
	if unlocked.is_empty():
		unlocked.assign(_library.slice(0, STARTING_UNLOCK_COUNT))


func unlock_random() -> Card:
	# Unlock a card the player doesn't own yet (compared by script/type,
	# since library instances are recreated).
	var owned_scripts: Array = unlocked.map(func(c: Card): return c.get_script())
	var pool := _library.filter(
		func(c: Card): return not owned_scripts.has(c.get_script())
	)
	if pool.is_empty():
		return null
	var card: Card = pool.pick_random()
	unlocked.append(card)
	loadout_changed.emit()
	print("New card unlocked: ", card.card_name, " - ", card.description)
	return card


func equip(card: Card) -> bool:
	if not unlocked.has(card):
		return false
	if equipped.size() == 3:
		return false
	equipped.append(card)
	loadout_changed.emit()
	return true


func remove(card: Card) -> bool:
	if not equipped.has(card):
		return false
	equipped.erase(card)
	loadout_changed.emit()
	return true


func list_equipped() -> Array[Card]:
	return equipped


func list_unlocked() -> Array[Card]:
	return unlocked
