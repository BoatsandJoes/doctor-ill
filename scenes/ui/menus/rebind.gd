extends CanvasLayer
class_name Rebind

signal back(keyboard: bool)

var Cursor = preload("res://scenes/ui/cursor.tscn")
var cursor: Cursor
var timer: Timer = Timer.new()
var listening: bool = false

var keyboard: bool
var gameButtons: bool
var vButtonIndex: int = 0
var hButtonIndex: int = 0

func _ready() -> void:
	timer.wait_time = 0.01
	timer.autostart = false
	timer.timeout.connect(_on_timer_timeout)
	timer.one_shot = true
	add_child(timer)
	timer.start()
	cursor = Cursor.instantiate()
	cursor.visible = false
	cursor.chosen.connect(_on_cursor_chosen)
	add_child(cursor)
	for i in range(0, %Buttons.get_children().size()):
		for button in %Buttons.get_children().get(i).get_children():
			button.pressed.connect(_on_button_pressed)

func _on_timer_timeout():
	set_cursor_position()
	cursor.visible = true

func _on_button_pressed():
	cursor.select()

func set_cursor_position():
	var button
	if vButtonIndex == -1:
		button = %Back
	else:
		button = %Buttons.get_children().get(hButtonIndex).get_children().get(vButtonIndex)
	cursor.position = button.global_position + Vector2(cursor.width * -1, button.size.y / 2)

func _on_cursor_chosen():
	if vButtonIndex == -1:
		emit_signal("back", keyboard)

func _input(event: InputEvent) -> void:
	if !cursor.is_animating():
		if !listening:
			if event.is_action_pressed("esc") || event.is_action_pressed("cancel"):
				emit_signal("back", keyboard)
			elif event.is_action_pressed("accept"):
				cursor.select()
			elif event.is_action_pressed("up"):
				if vButtonIndex <= -1:
					vButtonIndex = %Buttons.get_children().get(hButtonIndex).get_children().size() - 1
				else:
					vButtonIndex = vButtonIndex - 1
				set_cursor_position()
			elif event.is_action_pressed("down"):
				if vButtonIndex >= %Buttons.get_children().get(hButtonIndex).get_children().size() - 1:
					vButtonIndex = -1
				else:
					vButtonIndex = vButtonIndex + 1
				set_cursor_position()
			elif event.is_action_pressed("left"):
				if hButtonIndex <= 0:
					hButtonIndex = %Buttons.get_children().size() - 1
				else:
					hButtonIndex = hButtonIndex - 1
				set_cursor_position()
			elif event.is_action_pressed("right"):
				if hButtonIndex >= %Buttons.get_children().size() - 1:
					hButtonIndex = 0
				else:
					hButtonIndex = hButtonIndex + 1
				set_cursor_position()
		else:
			pass

func _on_up_mouse_entered():
	if !listening:
		vButtonIndex = 0
		hButtonIndex = 0
		set_cursor_position()

func _on_back_mouse_entered():
	if !listening:
		vButtonIndex = -1
		set_cursor_position()
