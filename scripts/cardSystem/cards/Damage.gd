class_name DamageCard
extends Card

@export var damage_mult := 2.0


func apply(player: Node) -> void:
	print("Damage Mult: " + damage_mult)
	
