extends Node2D
class_name Main

var game: GameManager
var menu
var lastTrack: int
var GameManager = preload("res://scenes/GameManager.tscn")
var MainMenu = preload("res://scenes/ui/menus/MainMenu.tscn")
var Credits = preload("res://scenes/ui/menus/Credits.tscn")

func _ready():
	get_tree().get_root().size_changed.connect(_on_root_size_changed)
	resize_window(640, 360)
	go_to_main_menu()

func resize_window(width: int, height: int):
	var newSize: Vector2i = Vector2i(width, height)
	get_window().position = get_window().position + (get_tree().get_root().size - newSize) / 2
	get_tree().get_root().size = newSize

func go_to_main_menu():
	remove_children()
	menu = MainMenu.instantiate()
	menu.exit.connect(_on_main_menu_exit)
	menu.play.connect(_on_main_menu_play)
	menu.credits.connect(_on_menu_credits)
	add_child(menu)

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

func _on_root_size_changed():
	pass
