extends CanvasLayer
class_name DeviceSelect

signal buttons(keyboard: bool, gameButtons: bool)
signal back

var Cursor = preload("res://scenes/ui/cursor.tscn")
var cursor: Cursor
var timer: Timer = Timer.new()
var buttonIndex: int = 0
var keyboard: bool
var gameButtons: bool
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
	for button in %Devices.get_children():
		button.pressed.connect(_on_button_pressed)
	for button in %Types.get_children():
		button.pressed.connect(_on_button_pressed)
	cursor.visible = false
	add_child(cursor)

func device_selected(keyboard: bool):
	self.keyboard = keyboard
	%Devices.visible = false
	%Types.visible = true
	%Title.text = "Keyboard" if keyboard else "Controller"

func device_deselected():
	%Devices.visible = true
	%Types.visible = false
	%Title.text = "Controls"
	buttonIndex = 0
	timer.start()

func _on_timer_timeout():
	set_cursor_position()
	cursor.visible = true

func _on_keyboard_mouse_entered():
	if !cursor.is_animating():
		buttonIndex = 0
		set_cursor_position()

func _on_controller_mouse_entered():
	if !cursor.is_animating():
		buttonIndex = 1
		set_cursor_position()

func _on_gameplay_mouse_entered():
	if !cursor.is_animating():
		buttonIndex = 0
		set_cursor_position()

func _on_menu_mouse_entered():
	if !cursor.is_animating():
		buttonIndex = 1
		set_cursor_position()

func _on_back_mouse_entered():
	if !cursor.is_animating():
		buttonIndex = 2
		set_cursor_position()

func set_cursor_position():
	var button
	if %Devices.visible:
		button = %Devices.get_children().get(buttonIndex)
	else:
		button = %Types.get_children().get(buttonIndex)
	cursor.position = button.global_position + Vector2(cursor.width * -1, button.size.y / 2)

func _on_cursor_chosen():
	if %Devices.visible:
		if buttonIndex >= %Devices.get_children().size() - 1:
			emit_signal("back")
		elif buttonIndex == 2:
			if %Reset.text == "Definitely reset controls?":
				%Reset.text = "All Controls Reset & Saved!"
				InputMap.load_from_project_settings()
			else:
				%Reset.text = "Definitely reset controls?"
		else:
			keyboard = buttonIndex == 0
			buttonIndex = 0
			%Devices.visible = false
			%Types.visible = true
			%Title.text = "Keyboard" if keyboard else "Controller"
			timer.start()
	else:
		if buttonIndex >= %Types.get_children().size() - 1:
			buttonIndex = 0
			%Devices.visible = true
			%Types.visible = false
			%Title.text = "Controls"
			timer.start()
		else:
			gameButtons = buttonIndex == 0
			emit_signal("buttons", keyboard, gameButtons)

func _input(event: InputEvent) -> void:
	if !cursor.is_animating():
		if event.is_action_pressed("esc") || event.is_action_pressed("cancel") || event.is_action_pressed("right_mouse"):
			if %Devices.visible:
				emit_signal("back")
			else:
				device_deselected()
		elif event.is_action_pressed("accept"):
			cursor.select()
		elif event.is_action_pressed("down") && downReleased:
			downReleased = false
			var max = 2 if %Types.visible else 3
			if buttonIndex >= max:
				buttonIndex = 0
			else:
				buttonIndex = buttonIndex + 1
			set_cursor_position()
		elif event.is_action_pressed("up") && upReleased:
			upReleased = false
			if buttonIndex <= 0:
				buttonIndex = 2 if %Types.visible else 3
			else:
				buttonIndex = buttonIndex - 1
			set_cursor_position()
		elif event.is_action_released("down"):
			downReleased = true
		elif event.is_action_released("up"):
			upReleased = true

func _on_button_pressed():
	cursor.select()

func _on_back_2_mouse_entered() -> void:
	if !cursor.is_animating():
		buttonIndex = 3
		set_cursor_position()

func _on_reset_mouse_entered() -> void:
	if !cursor.is_animating():
		buttonIndex = 2
		set_cursor_position()
