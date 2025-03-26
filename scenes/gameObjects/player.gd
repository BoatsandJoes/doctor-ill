extends Piece
class_name Player

enum stateType {IDLE, WALKING, TURNING, GRABBING_ONE, GRABBING_STACK, CLIMBING, KICKING}
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
var nonBufferedClimb: bool = false

func _ready() -> void:
	pass

func turn_around():
	$Sprite2D.scale = $Sprite2D.scale * Vector2(-1, 1)
	facing = facing * -1

func walk(tileWidth: int, delta: float) -> bool:
	$Sprite2D.position.x = $Sprite2D.position.x + (tileWidth * facing * delta) / defaultWalkCounter
	if abs($Sprite2D.position.x) >= tileWidth / 2:
		#clamp and flip to other side
		if $Sprite2D.position.x > 0:
			$Sprite2D.position.x = -tileWidth / 2
		else:
			$Sprite2D.position.x = tileWidth / 2
		return true
	return false

func climb(tileWidth: int, delta: float) -> bool:
	$Sprite2D.position.y = $Sprite2D.position.y - (tileWidth * delta) / defaultWalkCounter
	if abs($Sprite2D.position.y) >= tileWidth / 2:
		#clamp and flip to other side
		if $Sprite2D.position.y > 0:
			$Sprite2D.position.y = -tileWidth / 2
		else:
			$Sprite2D.position.y = tileWidth / 2
		return true
	return false

func fall(tileWidth: int, delta: float, stopAtMiddleOfTile: bool) -> bool:
	if !stopAtMiddleOfTile || $Sprite2D.position.y < 0:
		$Sprite2D.position.y = $Sprite2D.position.y + (tileWidth * delta) / defaultFallingCounter
		if abs($Sprite2D.position.y) >= tileWidth / 2:
			#clamp and flip to other side
			if $Sprite2D.position.y > 0:
				$Sprite2D.position.y = -tileWidth / 2
			else:
				$Sprite2D.position.y = tileWidth / 2
			return true
	else:
		$Sprite2D.position.y = 0
	return false

func climb_state():
	state = stateType.CLIMBING
	stateCountdown = defaultWalkCounter
	if facing == -1:
		$Sprite2D.rotation = PI / 2
	else:
		$Sprite2D.rotation = 3 * PI / 2

func idle_state():
	state = stateType.IDLE
	stateCountdown = 0
	$Sprite2D.position = Vector2i(0, $Sprite2D.position.y)
	$Sprite2D.rotation = 0
	nonBufferedClimb = false

func walk_state():
	state = stateType.WALKING
	stateCountdown = defaultWalkCounter
	$Sprite2D.position = Vector2i(0, 0)
	$Sprite2D.rotation = 0

func grabbing_state(stack: bool):
	if stack:
		state = stateType.GRABBING_STACK
	else:
		state = stateType.GRABBING_ONE
	stateCountdown = defaultPickupCounter

func center():
	$Sprite2D.position = Vector2i(0,0)

func vertically_centered() -> bool:
	return $Sprite2D.position.y == 0

func above_vertically_centered() -> bool:
	return $Sprite2D.position.y <= 0

func _input(event: InputEvent) -> void:
	if(event.is_action_pressed("pick_up_one")):
		bufferedPickUpOne = true
	elif(event.is_action_pressed("pick_up_stack")):
		bufferedPickUpStack = true
	elif(event.is_action_pressed("cycle")):
		bufferedCycle = true
	elif(event.is_action_pressed("kick")):
		bufferedKick = true;
	elif(event.is_action_pressed("up")):
		if state != stateType.CLIMBING:
			nonBufferedClimb = true
