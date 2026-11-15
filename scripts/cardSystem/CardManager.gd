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


func unlockable_cards() -> Array[Card]:
	# Cards the player has never unlocked (compared by script/type).
	var owned_scripts: Array = unlocked.map(func(c: Card): return c.get_script())
	return _library.filter(
		func(c: Card): return not owned_scripts.has(c.get_script())
	)


func unlock(card: Card) -> bool:
	# Adds a specific card to the collection (used by the death pick screen).
	var owned_scripts: Array = unlocked.map(func(c: Card): return c.get_script())
	if owned_scripts.has(card.get_script()):
		return false
	unlocked.append(card)
	loadout_changed.emit()
	Sfx.play("unlock", -3.0)
	return true


func equip(card: Card) -> bool:
	if not unlocked.has(card):
		return false
	if equipped.size() == 3:
		return false
	equipped.append(card)
	# Applying the card's effect requires the player; look it up here so
	# every equip path (menu drag, future UIs) applies automatically.
	var player = get_tree().get_first_node_in_group("player")
	if player:
		card.apply(player)
	loadout_changed.emit()
	Sfx.play("click", -4.0)
	return true


func remove(card: Card) -> bool:
	if not equipped.has(card):
		return false
	equipped.erase(card)
	loadout_changed.emit()
	Sfx.play("click", -10.0)
	return true


func list_equipped() -> Array[Card]:
	return equipped


func list_unlocked() -> Array[Card]:
	return unlocked
