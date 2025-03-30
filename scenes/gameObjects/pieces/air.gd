extends Piece
class_name Air

func _ready() -> void:
	matchVecs = [Vector2i(-1, -1), Vector2i(1, -1)]
	variety = 0

func set_bomb(_timeElapsed: float):
	pass
