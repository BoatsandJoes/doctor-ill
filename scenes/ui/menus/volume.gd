extends CanvasLayer
class_name Volume

signal back

var Cursor = preload("res://scenes/ui/cursor.tscn")
var cursor: Cursor
var timer: Timer = Timer.new()
var buttonIndex: int = 0
var buttonCalls: Array[Callable] = [cycle_volume, cycle_music, cycle_sfx, go_back]

func _ready() -> void:
	update_vol_label()
	update_music_label()
	update_sfx_label()
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

func cycle_volume():
	const interval = 0.2
	if AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Master")) >= 1.0:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), 0.0)
	elif AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Master")) <= 0.0:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), interval)
	else:
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"),
		AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Master")) + interval)
	update_vol_label()

func update_vol_label():
	%Buttons/Overall.text = "Overall " + str(int(floor(
		AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Master")) * 100))) + "%"

func cycle_music():
	const interval = 0.2
	if AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("music_vol")) >= 1.0:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("music_vol"), true)
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("music_vol"), 0.0)
	elif AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("music_vol")) <= 0.0:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("music_vol"), false)
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("music_vol"), interval)
	else:
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("music_vol"),
		AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("music_vol")) + interval)
	update_music_label()

func update_music_label():
	%Buttons/Music.text = "Music " + str(int(floor(
		AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("music_vol")) * 100))) + "%"

func cycle_sfx():
	const interval = 0.2
	if AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("sfx_vol")) >= 1.0:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("sfx_vol"), true)
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("sfx_vol"), 0.0)
	elif AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("sfx_vol")) <= 0.0:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("sfx_vol"), false)
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("sfx_vol"), interval)
	else:
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("sfx_vol"),
		AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("sfx_vol")) + interval)
	update_sfx_label()

func update_sfx_label():
	%Buttons/SFX.text = "SFX " + str(int(floor(
		AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("sfx_vol")) * 100))) + "%"

func go_back():
	emit_signal("back")

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

func _on_cursor_chosen():
	buttonCalls[buttonIndex].call()

func _on_overall_mouse_entered():
	if !cursor.is_animating():
		buttonIndex = 0
		set_cursor_position()

func _on_music_mouse_entered():
	if !cursor.is_animating():
		buttonIndex = 1
		set_cursor_position()

func _on_sfx_mouse_entered():
	if !cursor.is_animating():
		buttonIndex = 2
		set_cursor_position()

func _on_back_mouse_entered():
	if !cursor.is_animating():
		buttonIndex = 3
		set_cursor_position()
