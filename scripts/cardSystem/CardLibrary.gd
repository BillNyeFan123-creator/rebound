class_name CardLibrary
extends RefCounted
# The starting pool of unlocked cards. Each inner class is a card; stats and
# effect hooks live on player.gd. Add new cards here until they graduate to
# their own .tres files with icons and art.


static func get_all() -> Array[Card]:
	return [
		SharpenedBlade.new(),
		SwiftBoots.new(),
		FeatherCharm.new(),
		VitalityTonic.new(),
		GiantGreatsword.new(),
		QuickHands.new(),
		ShadowStep.new(),
		LongDash.new(),
		VampireFang.new(),
		IronSkin.new(),
		Bulwark.new(),
		Adrenaline.new(),
		Berserker.new(),
		GlassCannon.new(),
		ComebackSpirit.new(),
	]


class SharpenedBlade extends Card:
	func _init() -> void:
		card_name = "Sharpened Blade"
		description = "Deal double damage."
	func apply(player: Node) -> void:
		player.damage_mult *= 2.0


class SwiftBoots extends Card:
	func _init() -> void:
		card_name = "Swift Boots"
		description = "Move 35% faster."
	func apply(player: Node) -> void:
		player.speed_mult *= 1.35


class FeatherCharm extends Card:
	func _init() -> void:
		card_name = "Feather Charm"
		description = "Jump 30% higher."
	func apply(player: Node) -> void:
		player.jump_mult *= 1.3


class VitalityTonic extends Card:
	func _init() -> void:
		card_name = "Vitality Tonic"
		description = "+30 max health and heal 30."
	func apply(player: Node) -> void:
		player.max_health += 30
		player.heal(30)


class GiantGreatsword extends Card:
	func _init() -> void:
		card_name = "Giant Greatsword"
		description = "Attacks reach much further."
	func apply(player: Node) -> void:
		player.attack_radius_bonus += 25.0


class QuickHands extends Card:
	func _init() -> void:
		card_name = "Quick Hands"
		description = "Attack 35% faster."
	func apply(player: Node) -> void:
		player.attack_cd_mult *= 0.65


class ShadowStep extends Card:
	func _init() -> void:
		card_name = "Shadow Step"
		description = "Dash 40% more often."
	func apply(player: Node) -> void:
		player.dash_cd_mult *= 0.6


class LongDash extends Card:
	func _init() -> void:
		card_name = "Long Dash"
		description = "Dashes carry you much further."
	func apply(player: Node) -> void:
		player.dash_time_mult *= 1.6


class VampireFang extends Card:
	func _init() -> void:
		card_name = "Vampire Fang"
		description = "Heal 5 health on every kill."
	func apply(player: Node) -> void:
		player.heal_on_kill += 5.0


class IronSkin extends Card:
	func _init() -> void:
		card_name = "Iron Skin"
		description = "Take 30% less damage."
	func apply(player: Node) -> void:
		player.damage_taken_mult *= 0.7


class Bulwark extends Card:
	func _init() -> void:
		card_name = "Bulwark"
		description = "Take 15% less damage, but move 10% slower."
	func apply(player: Node) -> void:
		player.damage_taken_mult *= 0.85
		player.speed_mult *= 0.9


class Adrenaline extends Card:
	func _init() -> void:
		card_name = "Adrenaline"
		description = "Move 30% faster while below 30% health."
	func apply(player: Node) -> void:
		player.low_hp_speed_mult *= 1.3


class Berserker extends Card:
	func _init() -> void:
		card_name = "Berserker"
		description = "+50% damage, but take 20% more."
	func apply(player: Node) -> void:
		player.damage_mult *= 1.5
		player.damage_taken_mult *= 1.2


class GlassCannon extends Card:
	func _init() -> void:
		card_name = "Glass Cannon"
		description = "Triple damage, but take 50% more."
	func apply(player: Node) -> void:
		player.damage_mult *= 3.0
		player.damage_taken_mult *= 1.5


class ComebackSpirit extends Card:
	func _init() -> void:
		card_name = "Comeback Spirit"
		description = "Gain +25 max health every time you bounce back."
	func apply(player: Node) -> void:
		player.respawn_max_health_bonus += 25
