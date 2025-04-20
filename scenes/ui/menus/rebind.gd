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
var binds: Dictionary[StringName,Array] = {
	&"up": [],
	&"down": [],
	&"left": [],
	&"right": [],
	&"pick_up_one": [],
	&"pick_up_stack": [],
	&"kick": [],
	&"another": [],
	&"accept": [],
	&"cancel": [],
	&"pause": [],
	}

func _ready() -> void:
	if gameButtons:
		%Title.text = "Game Buttons  "
		# show correct buttons/labels
		for list in %Buttons.get_children():
			list.get_children()[4].visible = true
			list.get_children()[5].visible = true
			list.get_children()[6].visible = true
			list.get_children()[7].visible = true
			list.get_children()[8].visible = false
			list.get_children()[9].visible = false
			list.get_children()[10].visible = false
		%Labels.get_children()[4].visible = true
		%Labels.get_children()[5].visible = true
		%Labels.get_children()[6].visible = true
		%Labels.get_children()[7].visible = true
		%Labels.get_children()[8].visible = false
		%Labels.get_children()[9].visible = false
		%Labels.get_children()[10].visible = false
	else:
		%Title.text = "Menu Buttons  "
		# show correct buttons/labels
		for list in %Buttons.get_children():
			list.get_children()[4].visible = false
			list.get_children()[5].visible = false
			list.get_children()[6].visible = false
			list.get_children()[7].visible = false
			list.get_children()[8].visible = true
			list.get_children()[9].visible = true
			list.get_children()[10].visible = true
		%Labels.get_children()[4].visible = false
		%Labels.get_children()[5].visible = false
		%Labels.get_children()[6].visible = false
		%Labels.get_children()[7].visible = false
		%Labels.get_children()[8].visible = true
		%Labels.get_children()[9].visible = true
		%Labels.get_children()[10].visible = true
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
	#load action mappings into UI
	for i in range(binds.keys().size()):
		load_binds_to_ui(binds.keys()[i], i)

func load_binds_to_ui(key: StringName, index: int):
	# Load into dictionary first
	for event in InputMap.action_get_events(key):
		if keyboard && event is InputEventKey:
			binds[key].append(event)
		elif !keyboard:
			if event is InputEventJoypadButton:
				binds[key].append(event)
			elif event is InputEventJoypadMotion:
				binds[key].append(event)
	# Now put into UI
	for i in range(binds[key].size()):
		if i < %Buttons.get_children().size():
			if binds[key][i] is InputEventKey:
				%Buttons.get_children()[i].get_children()[index].text = (
					binds[key][i].as_text()
				)
			elif binds[key][i] is InputEventJoypadButton:
				if binds[key][i].as_text().find("(") != -1:
					%Buttons.get_children()[i].get_children()[index].text = (
						binds[key][i].as_text().substr(binds[key][i].as_text().find("(") + 1, -1)
					)
				else:
					%Buttons.get_children()[i].get_children()[index].text = (
						binds[key][i].as_text().substr(0, -1)
					)
			elif binds[key][i] is InputEventJoypadMotion:
				var text: String = ""
				if binds[key][i].axis == JOY_AXIS_LEFT_X:
					text = "Left Stick"
					if binds[key][i].axis_value < 0:
						text = text + " Left"
					elif binds[key][i].axis_value > 0:
						text = text + " Right"
				elif binds[key][i].axis == JOY_AXIS_LEFT_Y:
					text = "Left Stick"
					if binds[key][i].axis_value < 0:
						text = text + " Up"
					elif binds[key][i].axis_value > 0:
						text = text + " Down"
				elif binds[key][i].axis == JOY_AXIS_RIGHT_X:
					text = "Right Stick"
					if binds[key][i].axis_value < 0:
						text = text + " Left"
					elif binds[key][i].axis_value > 0:
						text = text + " Right"
				elif binds[key][i].axis == JOY_AXIS_RIGHT_Y:
					text = "Right Stick"
					if binds[key][i].axis_value < 0:
						text = text + " Up"
					elif binds[key][i].axis_value > 0:
						text = text + " Down"
				elif binds[key][i].axis == JOY_AXIS_TRIGGER_LEFT:
					text = "Left Trigger/L2/ZL"
				elif binds[key][i].axis == JOY_AXIS_TRIGGER_RIGHT:
					text = "Right Trigger/R2/ZR"
				%Buttons.get_children()[i].get_children()[index].text = (
					text
				)
			if %Buttons.get_children()[i].get_children()[index].text.length() > 19:
				%Buttons.get_children()[i].get_children()[index].text = (
					%Buttons.get_children()[i].get_children()[index].text.substr(0,18) + "-")
	if binds[key].size() < %Buttons.get_children().size():
		for i in range(binds[key].size(), %Buttons.get_children().size()):
			%Buttons.get_children()[i].get_children()[index].text = "<Unbound>"

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
		var buttonList = %Buttons.get_children().get(hButtonIndex)
		var j = -1
		for i in range(buttonList.get_children().size()):
			if buttonList.get_children()[i].visible:
				j = j + 1
			if j == vButtonIndex:
				button = buttonList.get_children()[i]
				break
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
					vButtonIndex = 7 if gameButtons else 6
				else:
					vButtonIndex = vButtonIndex - 1
				set_cursor_position()
			elif event.is_action_pressed("down"):
				var max = 7 if gameButtons else 6
				if vButtonIndex >= max:
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
