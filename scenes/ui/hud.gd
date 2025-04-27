extends CanvasLayer
class_name HUD

signal out_of_air

var maxAir: float = 99.99
var air: float = maxAir
var floor: int = 13
var allClears: int = 0
var clocksDestroyed: int = 0
var chill = false

func _ready() -> void:
	$AnimationPlayer.play("platino")

func update_air(delta: float, max: float):
	maxAir = max if !chill else 1000
	if !chill || delta > 0:
		air = min(air + delta, maxAir)
	if air < 0:
		air = 0
		emit_signal("out_of_air")
	elif air >= 11.0:
		%Air.modulate = Color(1,1,1)
	elif !chill:
		%Air.modulate = Color(1, 0.4, 0.4)
	%Air.text = str(int(air))

func set_floor(floor: int):
	if floor == 0:
		floor = 1
		#%TimeLabel.text = "Score"
		chill = true
		air = 0.99
	self.floor = floor
	%Floor.text = str(floor)

func next_floor():
	floor = floor + 1
	%Floor.text = str(floor)
	if floor > 13:
		win()

func win():
	pass

func destroyed():
	clocksDestroyed = clocksDestroyed + 1
	if get_parent().startingDepth + 1 + clocksDestroyed == 13:
		$Sprite2D.visible = true
	elif !%ClocksDestroyed.visible && $Sprite2D.visible:
		$Sprite2D.visible = false
		$Sprite2D2.visible = true
	%ClocksDestroyed.visible = true
	%DestroyedLabel.visible = true
	%ClocksDestroyed.text = str(clocksDestroyed)

func allClear():
	allClears = allClears + 1
	if get_parent().startingDepth + 1 + allClears == 13:
		if %ClocksDestroyed.visible:
			$Sprite2D2.visible = true
		else:
			$Sprite2D.visible = true
	%AllClears.visible = true
	%AllClearLabel.visible = true
	%AllClears.text = str(allClears)

func round_up_to_nearest_second():
	air = floor(air) + 0.999
