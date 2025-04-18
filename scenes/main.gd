extends Node2D
class_name Main

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
var graduated = false

func _ready():
	var baseSize = Vector2i(640, 360)
	var currSize = baseSize
	while !(currSize.x + baseSize.x >= DisplayServer.screen_get_size().x
	|| currSize.y + baseSize.y >= DisplayServer.screen_get_size().y):
		currSize = currSize + baseSize
	get_window().position = get_window().position + get_window().size / 2 - currSize / 2
	get_window().size = currSize
	
	go_to_main_menu()
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), 0.6)

func go_to_main_menu():
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
	menu.back.connect(go_to_main_menu)
	menu.config_controls.connect(go_to_button_config)
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

func _on_menu_credits():
	remove_children()
	menu = Credits.instantiate()
	menu.exit.connect(go_to_main_menu)
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
