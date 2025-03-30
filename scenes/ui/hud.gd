extends CanvasLayer
class_name HUD

signal out_of_air

var maxAir: float = 60.99
var air: float = maxAir

func update_air(delta: float, max: float):
	maxAir = max
	air = min(air + delta, maxAir)
	if air < 0:
		air = 0
		emit_signal("out_of_air")
	%Air.text = str(int(air))

func _physics_process(delta: float) -> void:
	update_air(-delta, maxAir)
