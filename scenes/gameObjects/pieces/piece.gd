extends Node2D
class_name Piece

var defaultFastFallCounter: float = 0.03
var defaultFallingCounter: float = 0.25
var fallingCounter: float = defaultFallingCounter
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

func set_ice():
	ice = true
	$Ice.visible = true

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
	if !flame:
		$Sprite2D.rotation = PI / 2
	else:
		$Sprite2D.rotation = PI

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
