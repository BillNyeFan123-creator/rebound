extends Node
# Simple one-shot SFX player. Autoload as "Sfx".
# Usage: Sfx.play("hurt") or Sfx.play("dash", -8.0)

const SOUNDS := {
	"attack": preload("res://assets/Sounds/SFX/sword_swing.wav"),
	"hit": preload("res://assets/Sounds/SFX/hit.ogg"),
	"jump": preload("res://assets/Sounds/SFX/jump.wav"),
	"kill": preload("res://assets/Sounds/SFX/kill.ogg"),
	"hurt": preload("res://assets/Sounds/SFX/hurt.ogg"),
	"dash": preload("res://assets/Sounds/SFX/dash.ogg"),
	"card_pick": preload("res://assets/Sounds/SFX/card_pick.ogg"),
	"unlock": preload("res://assets/Sounds/SFX/unlock.ogg"),
	"ui_open": preload("res://assets/Sounds/SFX/ui_open.ogg"),
	"ui_close": preload("res://assets/Sounds/SFX/ui_close.ogg"),
	"click": preload("res://assets/Sounds/SFX/click.ogg"),
	"respawn": preload("res://assets/Sounds/SFX/respawn.ogg"),
	"boss_spawn": preload("res://assets/Sounds/SFX/boss_spawn.ogg"),
}


func _ready() -> void:
	# Keep making sounds while the game is paused (card screens etc).
	process_mode = Node.PROCESS_MODE_ALWAYS


func play(sound_name: String, volume_db := 0.0) -> void:
	if not SOUNDS.has(sound_name):
		push_warning("Sfx: unknown sound '%s'" % sound_name)
		return
	var player := AudioStreamPlayer.new()
	player.stream = SOUNDS[sound_name]
	player.volume_db = volume_db
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)
