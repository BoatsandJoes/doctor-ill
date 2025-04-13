extends Piece
class_name Player

enum stateType {IDLE, WALKING, TURNING, GRABBING_ONE, GRABBING_STACK, CLIMBING, KICKING}
var state = stateType.IDLE
var facing: int = 1 # 1 == right, -1 == left
var defaultTurnaroundCounter: float = 0.15
var defaultWalkCounter: float = 0.2
var defaultPickupCounter: float = 0.06
var defaultKickCounter: float = 0.15
var kickPoint: float = 0.09
var bufferedPickUpOne: bool = false
var bufferedPickUpStack: bool = false
var bufferedCycle: bool = false
var bufferedKick: bool = false
var nonBufferedClimb: bool = false
var didAKick: bool = false

func _ready() -> void:
	type = -1
	variety = -1

func turn_around():
	$Sprite2D.scale = $Sprite2D.scale * Vector2(-1, 1)
	facing = facing * -1

func walk(tileWidth: int, delta: float) -> bool:
	$Sprite2D.position.x = $Sprite2D.position.x + (tileWidth * facing * delta) / defaultWalkCounter
	if abs($Sprite2D.position.x) >= tileWidth / 2:
		#clamp and flip to other side
		if $Sprite2D.position.x > 0:
			$Sprite2D.position.x = $Sprite2D.position.x - tileWidth
		else:
			$Sprite2D.position.x = $Sprite2D.position.x + tileWidth
		return true
	return false

func climb(tileWidth: int, delta: float) -> bool:
	$Sprite2D.position.y = $Sprite2D.position.y - (tileWidth * delta) / defaultWalkCounter
	if abs($Sprite2D.position.y) >= tileWidth / 2:
		#clamp and flip to other side
		if $Sprite2D.position.y > 0:
			$Sprite2D.position.y = $Sprite2D.position.y - tileWidth
		else:
			$Sprite2D.position.y = $Sprite2D.position.y + tileWidth
		return true
	return false

func fall(tileWidth: int, delta: float, stopAtMiddleOfTile: bool) -> bool:
	if !stopAtMiddleOfTile || $Sprite2D.position.y < 0:
		$Sprite2D.position.y = $Sprite2D.position.y + (tileWidth * delta) / defaultFallingCounter
		if abs($Sprite2D.position.y) >= tileWidth / 2:
			#clamp and flip to other side
			if $Sprite2D.position.y > 0:
				$Sprite2D.position.y = $Sprite2D.position.y - tileWidth
			else:
				$Sprite2D.position.y = $Sprite2D.position.y + tileWidth
			return true
	else:
		$Sprite2D.position.y = 0
	return false

func set_bomb(_secondsElapsed: float):
	pass

func climb_state():
	$AnimationPlayer.play("walk")
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
	if $AnimationPlayer.current_animation == "walk":
		$AnimationPlayer.play("RESET")

func walk_state():
	state = stateType.WALKING
	stateCountdown = defaultWalkCounter
	$Sprite2D.position = Vector2i(0, 0)
	$Sprite2D.rotation = 0
	$AnimationPlayer.play("walk")

func grabbing_state(stack: bool):
	if stack:
		state = stateType.GRABBING_STACK
	else:
		state = stateType.GRABBING_ONE
	stateCountdown = defaultPickupCounter
	$AnimationPlayer.play("pick_up")
	$AnimationPlayer.queue("RESET")

func put_down_animation():
	$AnimationPlayer.play("put_down")
	$AnimationPlayer.queue("RESET")

func is_this_the_part_where_we_start_kicking():
	state = stateType.KICKING
	$Sprite2D.rotation = 0
	stateCountdown = defaultKickCounter
	didAKick = false
	$AnimationPlayer.play("kick")
	$AnimationPlayer.queue("RESET")

func center():
	$Sprite2D.position = Vector2i(0,0)

func vertically_centered() -> bool:
	return $Sprite2D.position.y == 0

func above_vertically_centered() -> bool:
	return $Sprite2D.position.y <= 0

func lose():
	idle_state()
	$AnimationPlayer.play("lose")

func win():
	idle_state()
	$AnimationPlayer.play("win")

func _input(event: InputEvent) -> void:
	if(event.is_action_pressed("pick_up_one")):
		if Input.is_action_pressed("down") && !Input.is_action_pressed("up"):
			bufferedKick = true
		else:
			bufferedPickUpOne = true
	elif(event.is_action_pressed("pick_up_stack")):
		if Input.is_action_pressed("down") && !Input.is_action_pressed("up"):
			bufferedKick = true
		else:
			bufferedPickUpStack = true
	elif(event.is_action_pressed("kick")):
		bufferedKick = true;
	elif(event.is_action_pressed("up")):
		if state != stateType.CLIMBING:
			nonBufferedClimb = true
