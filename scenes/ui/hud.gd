extends CanvasLayer
class_name HUD

signal out_of_air

var maxAir: float = 99.99
var air: float = maxAir
var floor: int = 13
var allClears: int = 0
var clocksDestroyed: int = 0

func update_air(delta: float, max: float):
	maxAir = max
	air = min(air + delta, maxAir)
	if air < 0:
		air = 0
		emit_signal("out_of_air")
	%Air.text = str(int(air))

func set_floor(floor: int):
	self.floor = floor
	%Floor.text = str(floor)

func next_floor():
	round_up_to_nearest_second()
	if floor < 13:
		floor = floor + 1
		%Floor.text = str(floor)
	else:
		win()

func win():
	pass

func destroyed():
	clocksDestroyed = clocksDestroyed + 1
	%ClocksDestroyed.visible = true
	%DestroyedLabel.visible = true
	%ClocksDestroyed.text = str(clocksDestroyed)

func allClear():
	allClears = allClears + 1
	%AllClears.visible = true
	%AllClearLabel.visible = true
	%AllClears.text = str(allClears)

func round_up_to_nearest_second():
	air = floor(air) + 0.999

func _physics_process(delta: float) -> void:
	update_air(-delta, maxAir)
