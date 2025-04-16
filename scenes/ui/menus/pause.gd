extends CanvasLayer
class_name Pause

signal exit
signal restart

var Cursor = preload("res://scenes/ui/cursor.tscn")
var cursor: Cursor
var buttonIndex: int = 0
var timer: Timer = Timer.new()
var loseTimer: Timer = Timer.new()
var winTimer: Timer = Timer.new()
var buttonCalls: Array[Callable] = [_on_resume_pressed, _on_restart_pressed, _on_back_pressed]
var difficulty: String = ""
var time: String = ""

func _ready() -> void:
	visible = false
	timer.wait_time = 0.05
	timer.autostart = false
	timer.timeout.connect(_on_timer_timeout)
	timer.one_shot = true
	add_child(timer)
	loseTimer.wait_time = 1.2
	loseTimer.autostart = false
	loseTimer.timeout.connect(lose)
	loseTimer.one_shot = true
	add_child(loseTimer)
	winTimer.wait_time = (16.0 * 60.0) / 130.0
	winTimer.autostart = false
	winTimer.timeout.connect(win)
	winTimer.one_shot = true
	add_child(winTimer)
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

func lose():
	%NowPlaying.text = "No Hope (You died)"
	%Buttons/Resume.visible = false
	%Title.text = "Game"
	%Time.text = "Over"
	%Difficulty.text = time
	pause()

func win():
	%NowPlaying.text = "Boogie"
	%Buttons/Resume.visible = false
	%Title.text = "You Win!"
	%Difficulty.text = difficulty
	%Time.text = time
	pause()

func pause():
	get_tree().paused = true
	visible = true
	if %Buttons/Resume.visible:
		buttonIndex = 0
	elif %Buttons/Restart.visible:
		buttonIndex = 1
	else:
		buttonIndex = 2
	timer.start()

func _input(event: InputEvent) -> void:
	if loseTimer.is_stopped() && winTimer.is_stopped():
		if (event.is_action_pressed("esc") || event.is_action_pressed("pause")
		|| event.is_action_pressed("cancel")):
			if %Buttons/Resume.visible:
				get_viewport().set_input_as_handled()
				_on_resume_pressed()
		elif event.is_action_pressed("accept"):
			cursor.select()
		elif !cursor.is_animating():
			if event.is_action_pressed("down"):
				if buttonIndex >= %Buttons.get_children().size() - 1:
					if %Buttons/Resume.visible:
						buttonIndex = 0
					elif %Buttons/Restart.visible:
						buttonIndex = 1
					else:
						buttonIndex = 2
				else:
					buttonIndex = buttonIndex + 1
				set_cursor_position()
			elif event.is_action_pressed("up"):
				if (buttonIndex <= 0 || (!%Buttons/Resume.visible && buttonIndex <= 1)
				|| (!%Buttons/Restart.visible && buttonIndex <= 2)):
					buttonIndex = %Buttons.get_children().size() - 1
				else:
					buttonIndex = buttonIndex - 1
				set_cursor_position()
	elif (event.is_action_pressed("pause") || event.is_action_pressed("esc")):
		if !loseTimer.is_stopped():
			loseTimer.start(0.01)
		if !winTimer.is_stopped():
			winTimer.start(0.01)

func _on_button_pressed():
	cursor.select()

func _on_resume_pressed():
	buttonIndex = 0
	set_cursor_position()
	visible = false
	get_parent().boards[0].visible = true
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
