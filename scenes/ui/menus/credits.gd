extends Node2D
class_name Credits

signal exit

var speed = 60

func _ready() -> void:
	%Camera2D.make_current()
	$Node2D.position = Vector2(get_viewport().get_visible_rect().size.x / 2,
	get_viewport().get_visible_rect().size.y / -2)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		emit_signal("exit")
	elif event.is_action_pressed("accept"):
		speed = speed + 60
	elif event.is_action_pressed("cancel"):
		speed = speed - 60
		if speed < 0:
			emit_signal("exit")

func _process(delta: float) -> void:
	$Node2D.position.y = $Node2D.position.y + delta * speed
	if $Node2D.position.y > %Credits.size.y + 220:
		emit_signal("exit")

func _on_credits_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta).replace("\n", ""))
