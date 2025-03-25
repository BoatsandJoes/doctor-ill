extends Piece
class_name Player

enum stateType {IDLE, WALKING, TURNING, GRABBING, CLIMBING}
var state = stateType.IDLE
var facing: int = 1 # 1 == right, -1 == left
var defaultTurnaroundCounter: float = 0.15
var defaultWalkCounter: float = 0.2
var defaultPickupCounter: float = 0.06
var stateCountdown: float = 0
var bufferedPickUpOne: bool = false
var bufferedPickUpStack: bool = false
var bufferedCycle: bool = false
var bufferedKick: bool = false

func _ready() -> void:
	pass

func turn_around():
	$Sprite2D.scale = $Sprite2D.scale * Vector2(-1, 1)
	facing = facing * -1

func walk(tileWidth: int, delta: float) -> bool:
	$Sprite2D.position.x = $Sprite2D.position.x + (tileWidth * facing * delta) / defaultWalkCounter
	if abs($Sprite2D.position.x) >= tileWidth / 2:
		$Sprite2D.position.x = $Sprite2D.position.x * -1
		if abs($Sprite2D.position.x) > tileWidth / 2:
			pass # todo correct position if needed
		return true
	return false

func idle():
	state = stateType.IDLE
	stateCountdown = 0
	$Sprite2D.position = Vector2i(0,0)

func _input(event: InputEvent) -> void:
	if(event.is_action_pressed("pick_up_one")):
		bufferedPickUpOne = true
	elif(event.is_action_pressed("pick_up_stack")):
		bufferedPickUpStack = true
	elif(event.is_action_pressed("cycle")):
		bufferedCycle = true
	elif(event.is_action_pressed("kick")):
		bufferedKick = true;
