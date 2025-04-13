extends Node2D
class_name GameManager

signal exit(track: int)
signal restart(track: int, startingDepth: int)

var HUD = preload("res://scenes/ui/HUD.tscn")
var hud: HUD
var Board = preload("res://scenes/gameObjects/board.tscn")
var boards: Array[Board] = []
var Pause = preload("res://scenes/ui/menus/Pause.tscn")
var pause: Pause
var hatchOpen: bool = false
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
var startingDepth: int = -1

func _ready() -> void:
	hud = HUD.instantiate()
	add_child(hud)
	hud.out_of_air.connect(_on_hud_out_of_air)
	hud.set_floor(startingDepth + 2)
	music = AudioStreamPlayer.new()
	music.set_bus("Reduce")
	music.finished.connect(_on_music_finished)
	add_child(music)
	boards.append(Board.instantiate())
	for i in range(boards.size()):
		boards[i].depth = startingDepth
		add_child(boards[i])
		#multiple boards not actually handled oops
		boards[i].position = Vector2i(3 * boards[i].tilePixels / 2, boards[i].tilePixels / 2)
		boards[i].finished.connect(_on_board_finished)
		boards[i].won.connect(_on_board_won)
		boards[i].collect_air.connect(_on_board_collect_air)
		boards[i].destroy_clock.connect(_on_board_destroy_clock)
		boards[i].next_floor.connect(_on_board_next_floor)
		boards[i].all_clear.connect(hud.allClear)
		boards[i].hatch.connect(_on_board_hatch)
	play_random_song()
	pause = Pause.instantiate()
	pause.exit.connect(exit_game)
	pause.restart.connect(restart_game)
	add_child(pause)

func restart_game():
	emit_signal("restart", currentTrack, startingDepth)

func _on_board_hatch(hatchIndex: int):
	hatchOpen = true
	$doors.set_cell(Vector2i(hatchIndex + 1,11), 2, Vector2i(0,0))

func _on_board_next_floor():
	hatchOpen = false
	for i in range(1,8):
		$doors.set_cell(Vector2i(i,11), 1, Vector2i(0,0))
	hud.next_floor()

func _on_board_destroy_clock(quantity: float, max: float):
	hud.update_air(quantity / 2, max)
	hud.destroyed()

func _on_board_collect_air(quantity: float, max: float):
	hud.update_air(quantity, max)

func _on_hud_out_of_air():
	play_lose_animation()

func _on_board_finished():
	play_lose_animation()

func _on_board_won():
	play_win_animation()

func play_win_animation():
	var player = boards[0].players[0]
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	for audio in boards[0].sfx:
		audio.process_mode = Node.PROCESS_MODE_ALWAYS
	music.stream_paused = true
	player.win()
	pause.winTimer.start()
	get_tree().paused = true

func play_lose_animation():
	var player = boards[0].players[0]
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	for audio in boards[0].sfx:
		audio.process_mode = Node.PROCESS_MODE_ALWAYS
	boards[0].play_sfx(&"lose")
	music.stream_paused = true
	get_tree().paused = true
	player.lose()
	pause.loseTimer.start()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc") || event.is_action_pressed("pause"):
		if !pause.visible:
			get_viewport().set_input_as_handled()
			boards[0].visible = false
			pause.pause()

func exit_game():
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

func _physics_process(delta: float) -> void:
	if !hatchOpen:
		hud.update_air(-delta, hud.maxAir)
