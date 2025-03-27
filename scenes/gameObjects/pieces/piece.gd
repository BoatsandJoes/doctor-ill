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

func fall_fast():
	fastFall = true
	fallingCounter = defaultFastFallCounter

func off_center(direction: int) -> bool:
	return ((direction == 1 && $Sprite2D.position.x > 0) || (direction == -1 && $Sprite2D.position.x < 0)
	|| (direction == 0 && $Sprite2D.position.x != 0))

func toggle_bomb():
	bomb = !bomb
	if bomb:
		$Sprite2D.modulate = Color(5,5,5)
	else:
		$Sprite2D.modulate = Color(1,1,1)

func set_bomb():
	$Sprite2D.modulate = Color(5,5,5)
	bomb = true

func matches(piece: Piece) -> bool:
	return piece.type == type && piece.variety == variety
