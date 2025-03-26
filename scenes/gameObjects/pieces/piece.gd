extends Node2D
class_name Piece

var defaultFastFallCounter: float = 0.03
var defaultFallingCounter: float = 0.15
var fallingCounter: float = defaultFallingCounter
var fastFall: bool = false
var gridIndex: int
var bomb: bool = false

func off_center(direction: int) -> bool:
	return ((direction == 1 && $Sprite2D.position.x > 0) || (direction == -1 && $Sprite2D.position.x < 0)
	|| (direction == 0 && $Sprite2D.position.x != 0))

func toggle_bomb():
	bomb = !bomb
	if bomb:
		$Sprite2D.modulate = Color(3,3,3)
	else:
		$Sprite2D.modulate = Color(1,1,1)
