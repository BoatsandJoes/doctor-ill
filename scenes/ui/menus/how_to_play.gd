extends CanvasLayer
class_name HowToPlay

signal back

var Cursor = preload("res://scenes/ui/cursor.tscn")
var cursor: Cursor
var timer: Timer = Timer.new()
var buttonIndex: int = 1
var buttonCalls: Array[Callable] = [prev, next, go_back]
var leftReleased = true
var rightReleased = true
var advanced: bool = false

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

func advanced_mode():
	advanced = true
	%Advanced.visible = true
	%Slides.visible = false
	%Title.text = "Bonus Tips"

func _on_timer_timeout():
	set_cursor_position()
	add_child(cursor)

func set_cursor_position():
	var button = %Buttons.get_children().get(buttonIndex)
	cursor.position = button.global_position + Vector2(cursor.width * -1, button.size.y / 2)

func _input(event: InputEvent) -> void:
	if !cursor.is_animating():
		if event.is_action_pressed("esc"):
			emit_signal("back")
		elif event.is_action_pressed("cancel") || event.is_action_pressed("right_mouse"):
			if %Prev.disabled:
				emit_signal("back")
			else:
				prev()
		elif event.is_action_pressed("accept"):
			cursor.select()
		elif event.is_action_pressed("right") && rightReleased:
			rightReleased = false
			if buttonIndex >= %Buttons.get_children().size() - 1:
				buttonIndex = 0
			else:
				buttonIndex = buttonIndex + 1
			set_cursor_position()
		elif event.is_action_pressed("left") && leftReleased:
			leftReleased = false
			if buttonIndex <= 0:
				buttonIndex = %Buttons.get_children().size() - 1
			else:
				buttonIndex = buttonIndex - 1
			set_cursor_position()
		elif event.is_action_released("left"):
			leftReleased = true
		elif event.is_action_released("right"):
			rightReleased = true

func _on_button_pressed():
	cursor.select()

func _on_cursor_chosen():
	buttonCalls[buttonIndex].call()

func prev():
	if !%Prev.disabled:
		%Next.disabled = false
		var container = %Advanced if advanced else %Slides
		for i in range(container.get_children().size()):
			if container.get_children()[i].visible:
				container.get_children()[i].visible = false
				container.get_children()[i-1].visible = true
				if i <= 1:
					%Prev.disabled = true
				break

func next():
	if !%Next.disabled:
		%Prev.disabled = false
		var container = %Advanced if advanced else %Slides
		for i in range(container.get_children().size()):
			if container.get_children()[i].visible:
				container.get_children()[i].visible = false
				container.get_children()[i+1].visible = true
				if i >= container.get_children().size() - 2:
					%Next.disabled = true
				break

func go_back():
	emit_signal("back")

func _on_prev_mouse_entered() -> void:
	buttonIndex = 0
	set_cursor_position()

func _on_next_mouse_entered() -> void:
	buttonIndex = 1
	set_cursor_position()

func _on_exit_mouse_entered() -> void:
	buttonIndex = 2
	set_cursor_position()
