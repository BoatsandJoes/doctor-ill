extends Node2D
class_name TimeJuice

func _ready():
	$AnimationPlayer.animation_finished.connect(done)
	$AnimationPlayer.play(&"show")

func done(_animation: String):
	get_parent().remove_child(self)
	queue_free()
