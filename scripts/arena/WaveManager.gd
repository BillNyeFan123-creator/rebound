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
@export var small_enemy_scene: PackedScene  # faster, weaker type, mixed in from wave 2
@export var blue_enemy_scene: PackedScene   # third type, mixed in from wave 4
@export var boss_enemy_scene: PackedScene   # one spawns every 5th wave
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
	# Every 5th wave, a boss joins the roster.
	if boss_enemy_scene and wave % 5 == 0:
		_spawn_boss()
	print("Wave ", wave, " starting: ", to_spawn, " enemies")


func _spawn_boss() -> void:
	alive += 1
	var boss: Node2D = boss_enemy_scene.instantiate()
	boss.global_position = Vector2(576, 80)  # center ceiling, dramatic entrance
	boss.died.connect(_on_enemy_died)
	add_child(boss)
	print("A boss has appeared!")


func _spawn_enemy() -> void:
	to_spawn -= 1
	alive += 1
	var scene := enemy_scene
	# Roll for the mixed-in types, higher waves unlock nastier rosters.
	var roll := randf()
	if small_enemy_scene and wave >= 2 and roll < 0.35:
		scene = small_enemy_scene
	elif blue_enemy_scene and wave >= 4 and roll < 0.55:
		scene = blue_enemy_scene
	var enemy: Node2D = scene.instantiate()
	enemy.global_position = _random_edge_position()
	enemy.died.connect(_on_enemy_died)
	add_child(enemy)


func _random_edge_position() -> Vector2:
	# Spawn at the side walls or ceiling (never below the floor),
	# and never directly above/near the player (no drops on the head).
	var player := get_tree().get_first_node_in_group("player") as Node2D
	var last := Vector2(ARENA_MIN.x, ARENA_MIN.y)
	for i in 10:
		var x := randf_range(ARENA_MIN.x, ARENA_MAX.x)
		var y := randf_range(ARENA_MIN.y, ARENA_MAX.y)
		match randi() % 3:
			0: last = Vector2(ARENA_MIN.x, y)
			1: last = Vector2(ARENA_MAX.x, y)
			_: last = Vector2(x, ARENA_MIN.y)
		if player == null or absf(last.x - player.global_position.x) > 170.0:
			return last
	return last


func _on_enemy_died() -> void:
	alive -= 1
	player.on_enemy_killed()  # lifesteal cards hook in here
	if alive == 0 and to_spawn == 0:
		print("Wave ", wave, " cleared!")
		CardManager.unlock_random()  # clearing a wave unlocks a new card
		break_timer = BREAK_TIME


func _on_player_died() -> void:
	# Fizzle out: fade + shrink the knight, THEN pause and offer cards.
	var sprite = player.get_node_or_null("SpriteKnight")
	if sprite:
		var tw := sprite.create_tween()
		tw.set_parallel(true)
		tw.tween_property(sprite, "modulate:a", 0.0, 0.6)
		tw.tween_property(sprite, "scale", sprite.scale * 0.4, 0.6).set_ease(Tween.EASE_IN)
		tw.chain().tween_callback(_open_card_pick)
	else:
		_open_card_pick()


func _open_card_pick() -> void:
	# Guarantee 3 unequipped cards to offer, unlocking new ones on the spot
	# if the player owns too few.
	for i in 3:
		var candidates := CardManager.unlocked.filter(
			func(c: Card): return not CardManager.equipped.has(c)
		)
		if candidates.size() >= 3:
			break
		if CardManager.unlock_random() == null:
			break  # everything is unlocked
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
	# Death resets the run: clear the field and start over from wave 1.
	_reset_to_wave_one()


func _reset_to_wave_one() -> void:
	wave = 0
	alive = 0
	to_spawn = 0
	for child in get_children():
		if child is Enemy:
			child.queue_free()
	break_timer = 4.0  # calm moment after bouncing back before wave 1 comes in
