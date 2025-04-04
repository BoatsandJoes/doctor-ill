extends Node2D
class_name Main

var game: GameManager
var menu
var lastTrack: int
var GameManager = preload("res://scenes/GameManager.tscn")
var MainMenu = preload("res://scenes/ui/menus/MainMenu.tscn")
var Credits = preload("res://scenes/ui/menus/Credits.tscn")
var Settings = preload("res://scenes/ui/menus/Settings.tscn")

func _ready():
	get_window().position = get_window().position + get_window().size / 2 - Vector2i(1280, 720) / 2
	get_window().size = Vector2i(1280, 720)
	
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

func go_to_button_config():
	pass

func go_to_game():
	remove_children()
	game = GameManager.instantiate()
	game.currentTrack = lastTrack
	game.exit.connect(_on_game_exit)
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

func _on_main_menu_play():
	go_to_game()

func _on_main_menu_exit():
	get_tree().quit()
