extends CanvasLayer
class_name Settings

signal back
signal volume
signal config_controls

var Cursor = preload("res://scenes/ui/cursor.tscn")
var cursor: Cursor
var timer: Timer = Timer.new()
var buttonCalls: Array[Callable] = [cycle_resolution, cycle_volume, button_config, go_back]
var buttonIndex: int = 0
var scaleMult: int
var baseSize: Vector2i = Vector2i(640,360)

func _ready() -> void:
	timer.wait_time = 0.05
	timer.autostart = false
	timer.timeout.connect(_on_timer_timeout)
	timer.one_shot = true
	add_child(timer)
	timer.start()
	cursor = Cursor.instantiate()
	cursor.chosen.connect(_on_cursor_chosen)
	scaleMult = get_window().size.y / baseSize.y
	if scaleMult == 0:
		scaleMult = 1
	update_scale_label()

func _on_resolution_mouse_entered():
	buttonIndex = 0
	set_cursor_position()

func _on_volume_mouse_entered():
	buttonIndex = 1
	set_cursor_position()

func _on_controls_mouse_entered():
	buttonIndex = 2
	set_cursor_position()

func _on_back_mouse_entered():
	buttonIndex = 3
	set_cursor_position()

func _on_timer_timeout():
	set_cursor_position()
	add_child(cursor)

func set_cursor_position():
	var button = %Buttons.get_children().get(buttonIndex)
	cursor.position = button.global_position + Vector2(cursor.width * -1, button.size.y / 2)

func _on_cursor_chosen():
	if !%Buttons.get_children()[buttonIndex].disabled:
		buttonCalls[buttonIndex].call()

func _input(event: InputEvent) -> void:
	if !cursor.is_animating():
		if event.is_action_pressed("esc") || event.is_action_pressed("cancel"):
			emit_signal("back")
		elif event.is_action_pressed("accept"):
			cursor.select()
		elif event.is_action_pressed("down"):
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

func cycle_resolution():
	if get_window().mode == Window.MODE_FULLSCREEN:
		get_window().mode = Window.MODE_WINDOWED
		get_window().size = baseSize
		scaleMult = 1
		get_window().position = (get_window().position + DisplayServer.screen_get_size() / 2
		- (baseSize * scaleMult) / 2)
	elif (get_window().size.x + baseSize.x > DisplayServer.screen_get_size().x
	|| get_window().size.y + baseSize.y > DisplayServer.screen_get_size().y):
		get_window().mode = Window.MODE_FULLSCREEN
		#get_viewport().content_scale_size = baseSize * scaleMult
	else:
		#get_viewport().content_scale_size = get_viewport().content_scale_size + baseSize
		scaleMult = scaleMult + 1
		get_window().position = get_window().position + get_window().size / 2 - (baseSize * scaleMult) / 2
		get_window().size = baseSize * scaleMult
	update_scale_label()

func cycle_volume():
	emit_signal("volume")

func update_scale_label():
	if get_window().mode == Window.MODE_FULLSCREEN:
		%Buttons/Resolution.text = "Fullscreen"
	else:
		%Buttons/Resolution.text = "Windowed " + str(scaleMult) + "x"

func button_config():
	emit_signal("config_controls")

func go_back():
	emit_signal("back")
