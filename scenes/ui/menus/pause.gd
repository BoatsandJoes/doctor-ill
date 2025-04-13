extends CanvasLayer
class_name Pause

signal exit
signal restart

var Cursor = preload("res://scenes/ui/cursor.tscn")
var cursor: Cursor
var buttonIndex: int = 0
var timer: Timer = Timer.new()
var buttonCalls: Array[Callable] = [_on_resume_pressed, _on_restart_pressed, _on_back_pressed]

func _ready() -> void:
	visible = false
	timer.wait_time = 0.05
	timer.autostart = false
	timer.timeout.connect(_on_timer_timeout)
	timer.one_shot = true
	add_child(timer)
	cursor = Cursor.instantiate()
	cursor.visible = false
	add_child(cursor)
	cursor.chosen.connect(_on_cursor_chosen)

func _on_timer_timeout():
	set_cursor_position()
	cursor.visible = true

func _on_cursor_chosen():
	buttonCalls[buttonIndex].call()

func set_cursor_position():
	var button = %Buttons.get_children().get(buttonIndex)
	cursor.position = button.global_position + Vector2(cursor.width * -1, button.size.y / 2)

func pause():
	get_tree().paused = true
	visible = true
	buttonIndex = 0
	timer.start()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc") || event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		_on_resume_pressed()
	elif event.is_action_pressed("accept"):
		cursor.select()
	elif !cursor.is_animating():
		if event.is_action_pressed("down"):
			if buttonIndex >= %Buttons.get_children().size() - 1:
				buttonIndex = 0
			else:
				buttonIndex = buttonIndex + 1
			set_cursor_position()
		elif event.is_action_pressed("up"):
			if buttonIndex <= 0:
				buttonIndex = %Buttons.get_children().size() - 1
			else:
				buttonIndex = buttonIndex - 1
			set_cursor_position()

func _on_button_pressed():
	cursor.select()

func _on_resume_pressed():
	buttonIndex = 0
	set_cursor_position()
	visible = false
	get_tree().paused = false

func _on_restart_pressed():
	get_tree().paused = false
	emit_signal("restart")

func _on_back_pressed():
	get_tree().paused = false
	emit_signal("exit")

func _on_resume_mouse_entered() -> void:
	buttonIndex = 0
	set_cursor_position()

func _on_restart_mouse_entered() -> void:
	buttonIndex = 1
	set_cursor_position()

func _on_back_mouse_entered() -> void:
	buttonIndex = 2
	set_cursor_position()
