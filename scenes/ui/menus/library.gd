extends CanvasLayer
class_name Library

signal back
signal credits
signal how_to_play
signal advanced
signal scores

var Cursor = preload("res://scenes/ui/cursor.tscn")
var cursor: Cursor
var timer: Timer = Timer.new()
var buttonIndex: int = 0
var buttonCalls: Array[Callable] = [emit_how_to_play, emit_advanced, emit_credits, go_back]
var upReleased = true
var downReleased = true

func _ready() -> void:
	timer.wait_time = 0.01
	timer.autostart = false
	timer.timeout.connect(_on_timer_timeout)
	timer.one_shot = true
	add_child(timer)
	timer.start()
	cursor = Cursor.instantiate()
	cursor.chosen.connect(_on_cursor_chosen)
	for button in %Buttons.get_children():
		button.pressed.connect(_on_button_pressed)

func _on_timer_timeout():
	set_cursor_position()
	add_child(cursor)

func set_cursor_position():
	var button = %Buttons.get_children().get(buttonIndex)
	cursor.position = button.global_position + Vector2(cursor.width * -1, button.size.y / 2)

func emit_how_to_play():
	emit_signal("how_to_play")

func emit_scores():
	emit_signal("scores")

func emit_credits():
	emit_signal("credits")

func emit_advanced():
	emit_signal("advanced")

func go_back():
	emit_signal("back")

func _input(event: InputEvent) -> void:
	if !cursor.is_animating():
		if (event.is_action_pressed("esc") || event.is_action_pressed("cancel")
		|| event.is_action_pressed("right_mouse")):
			emit_signal("back")
		elif event.is_action_pressed("accept"):
			cursor.select()
		elif event.is_action_pressed("down") && downReleased:
			downReleased = false
			if buttonIndex >= %Buttons.get_children().size() - 1:
				buttonIndex = 0
			else:
				buttonIndex = buttonIndex + 1
			set_cursor_position()
		elif event.is_action_pressed("up") && upReleased:
			upReleased = false
			if buttonIndex <= 0:
				buttonIndex = %Buttons.get_children().size() - 1
			else:
				buttonIndex = buttonIndex - 1
			set_cursor_position()
		elif event.is_action_released("down"):
			downReleased = true
		elif event.is_action_released("up"):
			upReleased = true

func _on_button_pressed():
	cursor.select()

func _on_cursor_chosen():
	buttonCalls[buttonIndex].call()

func _on_how_to_play_mouse_entered():
	if !cursor.is_animating():
		buttonIndex = 0
		set_cursor_position()

func _on_scores_mouse_entered():
	if !cursor.is_animating():
		buttonIndex = 1
		set_cursor_position()

func _on_credits_mouse_entered():
	if !cursor.is_animating():
		buttonIndex = 2
		set_cursor_position()

func _on_back_mouse_entered():
	if !cursor.is_animating():
		buttonIndex = 3
		set_cursor_position()

func _on_advanced_mouse_entered() -> void:
	if !cursor.is_animating():
		buttonIndex = 1
		set_cursor_position()
