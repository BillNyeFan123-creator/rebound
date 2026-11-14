extends Node
# Arena wave system: spawns enemies in escalating waves. When the player dies,
# the game pauses and they bounce back with a card (pick 1 of 3), then respawn
# into the same fight — the wave keeps its progress.

const ARENA_MIN := Vector2(40, 80)     # spawn area, inset from screen edges
const ARENA_MAX := Vector2(1112, 500)  # keep above the floor so enemies can land
const SPAWN_INTERVAL := 0.6
const BREAK_TIME := 3.0
const BASE_WAVE_SIZE := 2

@export var enemy_scene: PackedScene
@export var pick_ui_path: NodePath

var wave := 0
var alive := 0
var to_spawn := 0
var spawn_timer := 0.0
var break_timer := 0.0
var between_waves := true

@onready var player: Node2D = get_node("../Player")
@onready var pick_ui := get_node(pick_ui_path)


func _ready() -> void:
	pick_ui.card_chosen.connect(_on_card_chosen)
	player.died.connect(_on_player_died)
	break_timer = 1.5  # short grace period before wave 1


func _process(delta: float) -> void:
	if to_spawn > 0:
		spawn_timer -= delta
		if spawn_timer <= 0.0:
			spawn_timer = SPAWN_INTERVAL
			_spawn_enemy()
	elif alive == 0:
		break_timer -= delta
		if break_timer <= 0.0:
			_start_next_wave()


func _start_next_wave() -> void:
	wave += 1
	to_spawn = BASE_WAVE_SIZE + wave
	spawn_timer = 0.0
	between_waves = false
	print("Wave ", wave, " starting: ", to_spawn, " enemies")


func _spawn_enemy() -> void:
	to_spawn -= 1
	alive += 1
	var enemy: Node2D = enemy_scene.instantiate()
	enemy.global_position = _random_edge_position()
	enemy.died.connect(_on_enemy_died)
	add_child(enemy)


func _random_edge_position() -> Vector2:
	# Spawn at the side walls or ceiling (never below the floor).
	var x := randf_range(ARENA_MIN.x, ARENA_MAX.x)
	var y := randf_range(ARENA_MIN.y, ARENA_MAX.y)
	match randi() % 3:
		0: return Vector2(ARENA_MIN.x, y)
		1: return Vector2(ARENA_MAX.x, y)
		_: return Vector2(x, ARENA_MIN.y)


func _on_enemy_died() -> void:
	alive -= 1
	player.on_enemy_killed()  # lifesteal cards hook in here
	if alive == 0 and to_spawn == 0:
		print("Wave ", wave, " cleared!")
		CardManager.unlock_random()  # clearing a wave unlocks a new card
		break_timer = BREAK_TIME


func _on_player_died() -> void:
	# Guarantee a proper choice: offer up to 3 cards, unlocking new ones
	# on the spot if the player owns too few unequipped cards.
	var offered := 0
	while offered < 3:
		var candidates := CardManager.unlocked.filter(
			func(c: Card): return not CardManager.equipped.has(c)
		)
		if candidates.size() <= offered:
			if CardManager.unlock_random() == null:
				break  # everything is unlocked
		else:
			offered = candidates.size()
	get_tree().paused = true
	pick_ui.open()


func _on_card_chosen(card: Card) -> void:
	# Bounce back: slots are fixed at 3, so a full loadout drops its oldest card.
	if CardManager.equipped.size() >= 3:
		CardManager.remove(CardManager.equipped[0])
	CardManager.equip(card)
	card.apply(player)  # newly equipped card takes effect right away
	pick_ui.close()
	get_tree().paused = false
	player.respawn()
	# The wave keeps its progress — remaining enemies stay where they are.
