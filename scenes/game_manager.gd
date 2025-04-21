extends Node2D
class_name GameManager

signal exit(track: int)
signal restart(track: int, startingDepth: int)

var queuePause: bool = false
var HUD = preload("res://scenes/ui/HUD.tscn")
var hud: HUD
var Board = preload("res://scenes/gameObjects/board.tscn")
var boards: Array[Board] = []
var Pause = preload("res://scenes/ui/menus/Pause.tscn")
var pause: Pause
var hatchOpen: bool = false
var music: AudioStreamPlayer
var trackTitles: Array[String] = [
	"Talk That Way",
	"Goes Like",
	"Humanity",
	"Psycho",
	"La Manera De Vivir",
	"Mess",
	"Escape",
	"Talk to Me",
	"All Night",
	"Take Me Away",
	"Grow",
	"Darkness Comes"
]
var musicTracks: Array[String] = [
"res://assets/music/JOXION - Talk That Way [NCS Release] (instrumental).mp3",
"res://assets/music/LOUD ABOUT US! - Goes Like [NCS Release].mp3",
"res://assets/music/Max Brhon - Humanity [NCS Release].mp3",
"res://assets/music/More Plastic & URBANO - Psycho [NCS Release] (instrumental).mp3",
"res://assets/music/NOYSE & ÆSTRØ - La Manera De Vivir [NCS Release] (instrumental).mp3",
"res://assets/music/SIIK & Alenn - Mess [NCS Release] (instrumental).mp3",
"res://assets/music/Sam Ourt, AKIAL & Srikar - Escape (Juan Dileju & Sam Ourt VIP Mix)"
+ " [NCS Release] (instrumental).mp3",
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
	music.set_bus("music")
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
	if startingDepth == -1:
		pause.difficulty = "Hard"
	elif startingDepth == 9:
		pause.difficulty = "Easy"
	elif startingDepth == 4:
		pause.difficulty = "Medium"
	add_child(pause)

func formatSeconds(seconds: float) -> String:
	var minutes: int = int(seconds) / 60
	var wholeSeconds: int = int(seconds) % 60
	var wholeSecondsStr: String = str(wholeSeconds)
	if wholeSecondsStr.length() <= 1:
		wholeSecondsStr = "0" + wholeSecondsStr
	var fraction: String = str(int((seconds - floor(seconds)) * 100))
	if fraction.length() <= 1:
		fraction = "0" + fraction
	return str(minutes) + ":" + wholeSecondsStr + "." + fraction

func restart_game():
	emit_signal("restart", currentTrack, startingDepth)

func _on_board_hatch(hatchIndex: int):
	hatchOpen = true
	$doors.set_cell(Vector2i(hatchIndex + 1,11), 2, Vector2i(0,0))

func _on_board_next_floor():
	hatchOpen = false
	for i in range(1,8):
		$doors.set_cell(Vector2i(i,11), 1, Vector2i(0,0))
	$Ceiling.set_cell(Vector2i(boards[0].players[0].gridIndex + 1,0), 1, Vector2i(0,0))
	var timer = Timer.new()
	timer.autostart = true
	timer.one_shot = true
	timer.wait_time = 0.88
	timer.timeout.connect(close_ceil)
	add_child(timer)
	hud.next_floor()
	boards[0].pause_clock_for(hud.air - floor(hud.air))

func close_ceil():
	for i in range(1,8):
		$Ceiling.set_cell(Vector2i(i,0), 0, Vector2i(0,0))

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
	hud.next_floor()
	boards[0].players[0].gridIndex = boards[0].players[0].gridIndex + boards[0].players[0].facing
	# replace floor
	for i in range(1,8):
		$doors.set_cell(Vector2i(i,11), 0, Vector2i(1,12))
	# replace ceiling
	$Ceiling.set_cell(Vector2i(boards[0].players[0].gridIndex,0), 1, Vector2i(0,0))
	pause.time = formatSeconds(boards[0].secondsElapsed)
	var player = boards[0].players[0]
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	for audio in boards[0].sfx:
		audio.process_mode = Node.PROCESS_MODE_ALWAYS
	pause.play(&"win")
	music.stream_paused = true
	player.win("")
	player.play_falling()
	pause.winTimer.start()
	get_tree().paused = true

func play_lose_animation():
	pause.time = formatSeconds(boards[0].secondsElapsed)
	var player = boards[0].players[0]
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	for audio in boards[0].sfx:
		audio.process_mode = Node.PROCESS_MODE_ALWAYS
	pause.play(&"lose")
	music.stream_paused = true
	get_tree().paused = true
	player.lose()
	pause.loseTimer.start()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc") || event.is_action_pressed("pause"):
		if !pause.visible:
			get_viewport().set_input_as_handled()
			queuePause = true

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
	if queuePause:
		queuePause = false
		boards[0].visible = false
		pause.get_node("%NowPlaying").text = trackTitles[currentTrack]
		pause.pause()
