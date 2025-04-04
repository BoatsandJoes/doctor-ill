extends Node2D
class_name Cursor

var width: int = 16
var timer: Timer

signal chosen

func _ready() -> void:
	$AnimationPlayer.animation_set_next("choose", "idle")

func select():
	$AnimationPlayer.play("choose")
	timer = Timer.new()
	timer.autostart = false
	timer.one_shot = true
	timer.wait_time = 4.0/60.0
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	timer.start()

func is_animating():
	return timer != null && !timer.is_stopped()

func _on_timer_timeout():
	remove_child(timer)
	timer.queue_free()
	timer = null
	emit_signal("chosen")
