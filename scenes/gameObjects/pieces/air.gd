extends Piece
class_name Air

func _ready() -> void:
	matchVecs = [Vector2i(-1, -1), Vector2i(1, -1)]
	variety = 0
	$AnimationPlayer.play("tick_tock") #todo sync with visible timer on level advance
	#(maybe advance on a frame rule. Or top off the time to the nearest whole second: that's nicer)

func set_bomb(_timeElapsed: float):
	pass
