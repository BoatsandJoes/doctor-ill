extends CanvasLayer
class_name MainMenu

signal exit
signal play
signal settings
signal credits

var buttonIndex: int = 0
var Cursor = preload("res://scenes/ui/cursor.tscn")
var cursor: Cursor
var timer: Timer = Timer.new()
var buttonCalls: Array[Callable] = [_on_play_pressed, _on_credits_pressed, _on_settings_pressed,
_on_exit_pressed]
var upReleased = true
var downReleased = true

func _ready() -> void:
	timer.wait_time = 0.05
	timer.autostart = false
	timer.timeout.connect(_on_timer_timeout)
	timer.one_shot = true
	add_child(timer)
	timer.start()
	cursor = Cursor.instantiate()
	cursor.chosen.connect(_on_cursor_chosen)

func _on_timer_timeout():
	set_cursor_position()
	add_child(cursor)

func set_cursor_position():
	var button = %Buttons.get_children().get(buttonIndex)
	cursor.position = button.global_position + Vector2(cursor.width * -1, button.size.y / 2)

func _on_cursor_chosen():
	buttonCalls[buttonIndex].call()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		_on_exit_pressed()
	elif !cursor.is_animating():
		if event.is_action_pressed("accept"):
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

func _on_play_pressed() -> void:
	emit_signal("play")

func _on_settings_pressed() -> void:
	emit_signal("settings")

func _on_credits_pressed() -> void:
	emit_signal("credits")

func _on_exit_pressed() -> void:
	emit_signal("exit")

func _on_play_mouse_entered() -> void:
	buttonIndex = 0
	set_cursor_position()

func _on_settings_mouse_entered() -> void:
	buttonIndex = 2
	set_cursor_position()

func _on_credits_mouse_entered() -> void:
	buttonIndex = 1
	set_cursor_position()

func _on_exit_mouse_entered() -> void:
	buttonIndex = 3
	set_cursor_position()
