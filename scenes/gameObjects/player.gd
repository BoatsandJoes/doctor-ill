extends Piece
class_name Player

var facing: int = 1 # 1 == right, -1 == left
var directionPressed: Vector2i = Vector2i(0,0)
var defaultTurnaroundCounter: float = 0.15
var turnaroundCounter: float = defaultTurnaroundCounter
var defaultWalkCounter: float = 0.2
var walkCounter: float = defaultWalkCounter
const defaultPosition: Vector2i = Vector2i(0,0)
var bufferedPickUpOne: bool = false
var bufferedPickUpStack: bool = false
var bufferedCycle: bool = false
var bufferedKick: bool = false

func _ready() -> void:
	$Sprite2D.position = defaultPosition

func _input(event: InputEvent) -> void:
	if(event.is_action_pressed("pick_up_one")):
		bufferedPickUpOne = true
	elif(event.is_action_pressed("pick_up_stack")):
		bufferedPickUpStack = true
	elif(event.is_action_pressed("cycle")):
		bufferedCycle = true
	elif(event.is_action_pressed("kick")):
		bufferedKick = true;
