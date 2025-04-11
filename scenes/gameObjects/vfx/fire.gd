extends Node2D
class_name Fire

func _ready() -> void:
	$AnimationPlayer.play("explode")
	$AnimationPlayer.animation_finished.connect(end)

func end(_animation: String):
	get_parent().remove_child(self)
	queue_free()
