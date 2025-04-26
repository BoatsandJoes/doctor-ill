extends Node2D
class_name Main

var inputKeys: Array[StringName] = [&"up",&"down",&"left",&"right",
&"pick_up_one",&"pick_up_stack",&"kick",&"another",&"accept",&"cancel",&"pause"]
const save_path := "user://down-the-match-save.dat"
var game: GameManager
var menu
var lastTrack: int
var GameManager = preload("res://scenes/GameManager.tscn")
var MainMenu = preload("res://scenes/ui/menus/MainMenu.tscn")
var Credits = preload("res://scenes/ui/menus/Credits.tscn")
var Settings = preload("res://scenes/ui/menus/Settings.tscn")
var Difficulty = preload("res://scenes/ui/menus/Difficulty.tscn")
var DeviceSelect = preload("res://scenes/ui/menus/DeviceSelect.tscn")
var Rebind = preload("res://scenes/ui/menus/Rebind.tscn")
var Volume = preload("res://scenes/ui/menus/Volume.tscn")
var Library = preload("res://scenes/ui/menus/Library.tscn")
var HowToPlay = preload("res://scenes/ui/menus/HowToPlay.tscn")
var graduated = false
var oldGraduated = false

func _ready():
	load_save()
	go_to_main_menu()

func load_save():
	var setResolution: bool = true
	var setVolume: bool = true
	# load save
	if FileAccess.file_exists(save_path):
		var file := FileAccess.open(save_path, FileAccess.READ)
		var error = FileAccess.get_open_error()
		if error == 0: #Error.OK
			file.get_8() #Version
			var g = file.get_8()
			if g == 1:
				oldGraduated = true
				graduated = true
			#Volume
			var vol = file.get_float()
			if vol != null:
				AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), vol)
				if vol <= 0.0:
					AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
			var mvol = file.get_float()
			if mvol != null:
				AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("music_vol"), mvol)
				if mvol <= 0.0:
					AudioServer.set_bus_mute(AudioServer.get_bus_index("music_vol"), true)
			var svol = file.get_float()
			if svol != null:
				AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("sfx_vol"), svol)
				if svol <= 0.0:
					AudioServer.set_bus_mute(AudioServer.get_bus_index("sfx_vol"), true)
			setVolume = false
			# Resolution
			var scaleMult = file.get_8()
			if scaleMult == null || scaleMult == 0:
				scaleMult = 1
			if scaleMult > 1:
				var currSize = Vector2i(640, 360) * scaleMult
				get_window().position = get_window().position + get_window().size / 2 - currSize / 2
				get_window().size = currSize
			# Fullscreen: 1 or 0
			var fullscreen = file.get_8()
			if fullscreen == Window.MODE_FULLSCREEN:
				get_window().mode = fullscreen
			setResolution = false
			# controls
			for key in inputKeys:
				InputMap.action_erase_events(key)
				var count: int = file.get_8() #Number of events for this action
				for i in range(count):
					var type = file.get_8()
					#Get event type, then load event information
					var event
					if type == 1:
						event = InputEventKey.new()
						var pressed: int = file.get_8()
						event.pressed = pressed == 1
						event.keycode = file.get_64()
						event.physical_keycode = file.get_64()
						event.key_label = file.get_64()
						event.unicode = file.get_64()
						event.location = file.get_64()
						event.device = file.get_64()
						#implicitly, echo = false and all modifier keys off and window = 0
					elif type == 2:
						event = InputEventJoypadButton.new()
						event.button_index = file.get_8()
						event.pressure = file.get_float()
						var pressed: int = file.get_8()
						event.pressed = pressed == 1
						event.device = file.get_64()
					elif type == 3:
						event = InputEventJoypadMotion.new()
						var axis = file.get_64()
						event.axis = axis
						event.axis_value = file.get_float()
						event.device = file.get_64()
					InputMap.action_add_event(key, event)
			file.close()
	if setResolution: #default
		var baseSize = Vector2i(640, 360)
		var currSize = baseSize
		while !(currSize.x + baseSize.x >= DisplayServer.screen_get_size().x
		|| currSize.y + baseSize.y >= DisplayServer.screen_get_size().y):
			currSize = currSize + baseSize
		get_window().position = get_window().position + get_window().size / 2 - currSize / 2
		get_window().size = currSize
	if setVolume: #default
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), 0.6) 

func save_and_go_to_main_menu():
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	var error = FileAccess.get_open_error()
	if error == 0: #Error.OK
		file.store_8(18) #Version
		if graduated:
			file.store_8(1)
		else:
			file.store_8(0)
		#Volume
		file.store_float(AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Master")))
		file.store_float(AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("music_vol")))
		file.store_float(AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("sfx_vol")))
		# Resolution
		var scaleMult = get_window().size.y / 360
		if scaleMult == 0:
			scaleMult = 1
		file.store_8(scaleMult) #1x 2x 3x screen size
		# Fullscreen
		file.store_8(get_window().mode)
		# controls
		var inputs: Dictionary = {}
		for key in inputKeys:
			inputs[key] = InputMap.action_get_events(key)
			if inputs[key] == null:
				inputs[key] = []
			file.store_8(inputs[key].size()) #Number of events for this action
			for i in range(inputs[key].size()):
				var event = inputs[key][i]
				#Store event type, then store event information
				if event is InputEventKey:
					file.store_8(1) #type
					var pressed: int = 1 if event.pressed else 0
					file.store_8(pressed)
					file.store_64(event.keycode)
					file.store_64(event.physical_keycode)
					file.store_64(event.key_label)
					file.store_64(event.unicode)
					file.store_64(event.location)
					file.store_64(-1) #device
					#implicitly, echo = false and all modifier keys off and window = 0
				elif event is InputEventJoypadButton:
					file.store_8(2) #type
					file.store_8(event.button_index)
					file.store_float(event.pressure)
					var pressed: int = 1 if event.pressed else 0
					file.store_8(pressed)
					file.store_64(-1) # device
				elif event is InputEventJoypadMotion:
					file.store_8(3) #type
					file.store_64(event.axis)
					file.store_float(event.axis_value)
					file.store_64(-1) #this way next session will preserve buttons even if device id changes
		file.close()
	go_to_main_menu()

func go_to_main_menu():
	if graduated && !oldGraduated:
		oldGraduated = true
		save_and_go_to_main_menu()
	else:
		remove_children()
		menu = MainMenu.instantiate()
		menu.exit.connect(_on_main_menu_exit)
		menu.play.connect(_on_main_menu_play)
		menu.credits.connect(_on_menu_credits)
		menu.settings.connect(go_to_settings)
		add_child(menu)

func go_to_settings():
	remove_children()
	menu = Settings.instantiate()
	menu.back.connect(save_and_go_to_main_menu)
	menu.config_controls.connect(go_to_button_config)
	menu.volume.connect(go_to_volume)
	add_child(menu)

func go_to_volume():
	remove_children()
	menu = Volume.instantiate()
	menu.back.connect(go_to_settings)
	add_child(menu)

func go_to_difficulty():
	remove_children()
	menu = Difficulty.instantiate()
	menu.back.connect(go_to_main_menu)
	menu.start.connect(go_to_game)
	add_child(menu)

func go_to_button_config():
	remove_children()
	menu = DeviceSelect.instantiate()
	menu.back.connect(go_to_settings)
	menu.buttons.connect(go_to_rebind)
	add_child(menu)

func go_to_button_config_for_device(keyboard: bool):
	go_to_button_config()
	menu.device_selected(keyboard)

func go_to_rebind(keyboard: bool, gameButtons: bool):
	remove_children()
	menu = Rebind.instantiate()
	menu.keyboard = keyboard
	menu.gameButtons = gameButtons
	menu.back.connect(go_to_button_config_for_device)
	add_child(menu)

func go_to_game(depth: int):
	remove_children()
	game = GameManager.instantiate()
	game.currentTrack = lastTrack
	game.exit.connect(_on_game_exit)
	game.startingDepth = depth
	game.restart.connect(_on_game_restart)
	add_child(game)

func remove_children():
	if game != null:
		remove_child(game)
		game.queue_free()
	if menu != null:
		remove_child(menu)
		menu.queue_free()

func go_to_how_to_play():
	remove_children()
	menu = HowToPlay.instantiate()
	menu.back.connect(_on_menu_credits)
	add_child(menu)

func go_to_advanced():
	remove_children()
	menu = HowToPlay.instantiate()
	menu.advanced_mode()
	menu.back.connect(_on_menu_credits)
	add_child(menu)

func go_to_scores():
	pass

func _on_menu_credits():
	remove_children()
	menu = Library.instantiate()
	menu.back.connect(go_to_main_menu)
	menu.credits.connect(go_to_credits)
	menu.advanced.connect(go_to_advanced)
	menu.how_to_play.connect(go_to_how_to_play)
	menu.scores.connect(go_to_scores)
	add_child(menu)

func go_to_credits():
	remove_children()
	menu = Credits.instantiate()
	menu.exit.connect(_on_menu_credits)
	add_child(menu)

func _on_game_exit(track: int):
	lastTrack = track
	go_to_main_menu()

func _on_game_restart(track: int, depth: int):
	lastTrack = track
	go_to_game(depth)

func _on_main_menu_play():
	go_to_difficulty()

func _on_main_menu_exit():
	get_tree().quit()
