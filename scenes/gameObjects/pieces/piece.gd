extends Node2D
class_name Piece

var defaultFastFallCounter: float = 0.03
var defaultFallingCounter: float = 0.25
var fallingCounter: float = defaultFallingCounter
var defaultSlideCounter: float = 0.03
var stateCountdown: float = 0
var fastFall: bool = false
var gridIndex: int
var bomb: bool = false
var matchVecs: Array[Vector2i] = []
var type: int
var variety: int
var bombCreationTime: float = 0.0
var flame: bool = false
var flameSize: int = 4
var lightning: bool = false
var ice: bool = false
var kicked: int = 0
var coyoteTime: int = -1
var lightningFrameHold: float = 0.1
var lightingFrameTime: float = lightningFrameHold

func set_ice():
	ice = true
	$Ice.visible = true
	$AnimationPlayer.play("RESET")

func melt_ice():
	ice = false
	$Ice.visible = false

func set_flame(size: int):
	flame = true
	flameSize = size
	if !lightning:
		$Sprite2D.rotation = 3 * PI / 2
	else:
		$Sprite2D.rotation = PI

func set_lightning():
	lightning = true
	$Lightning.visible = true

func revert_special():
	lightning = false
	flame = false
	$Sprite2D.rotation = 0
	$Lightning.visible = false

func fall_fast():
	fastFall = true
	fallingCounter = defaultFastFallCounter

func off_center(direction: int) -> bool:
	return ((direction == 1 && $Sprite2D.position.x > 0) || (direction == -1 && $Sprite2D.position.x < 0)
	|| (direction == 0 && $Sprite2D.position.x != 0))

func toggle_bomb(secondsElapsed: float):
	bomb = !bomb
	if bomb:
		$Sprite2D.modulate = Color(5,5,5)
		bombCreationTime = secondsElapsed
	else:
		$Sprite2D.modulate = Color(1,1,1)

func set_bomb(secondsElapsed: float):
	if !ice:
		$Sprite2D.modulate = Color(5,5,5)
		bomb = true
		bombCreationTime = secondsElapsed

func matches(piece: Piece) -> bool:
	return piece.type == type && piece.variety == variety && !ice && !piece.ice

func kick(facing: int):
	if !ice:
		kicked = facing
		stateCountdown = defaultSlideCounter

func bonk():
	kicked = 0
	fall_fast()
