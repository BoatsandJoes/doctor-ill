extends Node2D
class_name Cursor

var width: int = 16
var timer: Timer
var sfx: AudioStreamPlayer
var click = preload("res://assets/sfx/click3.ogg")

signal chosen

func _ready() -> void:
	sfx = AudioStreamPlayer.new()
	sfx.set_bus("sfx")
	sfx.stream = click
	add_child(sfx)
	$AnimationPlayer.animation_set_next("choose", "idle")

func select():
	sfx.play()
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
