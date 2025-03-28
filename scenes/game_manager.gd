extends Node2D
class_name GameManager

signal exit(track: int)

var HUD = preload("res://scenes/ui/HUD.tscn")
var hud: HUD
var Board = preload("res://scenes/gameObjects/board.tscn")
var boards: Array[Board] = []

var music: AudioStreamPlayer
var musicTracks: Array[String] = [
"res://assets/music/JOXION - Talk That Way [NCS Release] (instrumental).mp3",
"res://assets/music/LOUD ABOUT US! - Goes Like [NCS Release].mp3",
"res://assets/music/Max Brhon - Humanity [NCS Release].mp3",
"res://assets/music/More Plastic & URBANO - Psycho [NCS Release] (instrumental).mp3",
"res://assets/music/NOYSE & ÆSTRØ - La Manera De Vivir [NCS Release] (instrumental).mp3",
"res://assets/music/SIIK & Alenn - Mess [NCS Release] (instrumental).mp3",
"res://assets/music/Sam Ourt, AKIAL & Srikar - Escape (Juan Dileju & Sam Ourt VIP Mix) [NCS Release] (instrumental).mp3",
"res://assets/music/Siberian Express - Talk To Me [NCS Release] (instrumental).mp3",
"res://assets/music/Toxic Joy - All Night [NCS Release] (instrumental).mp3",
"res://assets/music/Track NATSUMI - Take Me Away [NCS Release].mp3",
"res://assets/music/Alisky - Grow (feat. VØR) [NCS Release] (instrumental).mp3",
"res://assets/music/Approaching Nirvana & Alex Holmes - Darkness Comes [NCS Release] (instrumental).mp3"
]
var currentTrack: int

func _ready() -> void:
	hud = HUD.instantiate()
	add_child(hud)
	hud.out_of_air.connect(_on_hud_out_of_air)
	music = AudioStreamPlayer.new()
	music.set_bus("Reduce")
	music.finished.connect(_on_music_finished)
	add_child(music)
	boards.append(Board.instantiate())
	for i in range(boards.size()):
		add_child(boards[i])
		#todo handle multiple boards
		boards[i].position = Vector2i(boards[i].tilePixels / 2, boards[i].tilePixels / 2)
		boards[i].finished.connect(_on_board_finished)
		boards[i].collect_air.connect(_on_board_collect_air)
	play_random_song()

func _on_board_collect_air(quantity: float):
	hud.update_air(quantity)

func _on_hud_out_of_air():
	emit_signal("exit", currentTrack)

func _on_board_finished():
	emit_signal("exit", currentTrack)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		emit_signal("exit", currentTrack)

func _on_music_finished():
	play_random_song()

func play_random_song():
	var choice: int = currentTrack
	while choice == currentTrack:
		choice = randi() % musicTracks.size()
	music.stream = load(musicTracks[choice])
	currentTrack = choice
	music.play()
