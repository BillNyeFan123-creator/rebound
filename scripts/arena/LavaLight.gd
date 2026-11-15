extends PointLight2D
# Pulses the lava glow so the floor feels alive.

var _time := 0.0
var _base_energy := 0.8


func _ready() -> void:
	_base_energy = energy


func _process(delta: float) -> void:
	_time += delta
	energy = _base_energy + sin(_time * 1.7) * 0.18 + sin(_time * 4.3) * 0.06
