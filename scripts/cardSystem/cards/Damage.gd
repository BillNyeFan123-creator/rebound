class_name DamageCard
extends Card

@export var damage_mult := 2.0


func _init() -> void:
	card_name = "Sharpened Blade"
	description = "Deal double damage."


func apply(player: Node) -> void:
	player.damage_mult *= damage_mult
	print("Damage Mult: ", player.damage_mult)

	
