extends Node2D
class_name Board

var Omni = preload("res://scenes/gameObjects/pieces/Omni.tscn")
var Diag = preload("res://scenes/gameObjects/pieces/Diag.tscn")
var Player = preload("res://scenes/gameObjects/player.tscn")
var generator: Generator = Generator.new()
var players: Array[Player] = []
var depth: int = -1
var board: Array
var tilePixels: int = 16
var paramsList: Array[Dictionary] = [
	{&"width": 7, &"height": 7, &"buffer": 4, &"types": [Omni, Diag], &"colors": 3}
]
var currentParams: Dictionary = paramsList[0]

func _ready() -> void:
	players.append(Player.instantiate())
	for playerNum in range(players.size()):
		add_child(players[playerNum])
		# evenly distribute the players
		players[playerNum].gridIndex = (currentParams[&"width"] * (playerNum + 1)) / (players.size() * 2)
	generateNextFloor()
	updateVisualPositions()

func updateVisualPositions() -> void:
	for i in range(board.size()):
		if board[i] != null:
			updateVisualPosition(i)

func getPositionForIndex(i: int) -> Vector2i:
	var x = tilePixels * (i % currentParams[&"width"])
	var y = tilePixels * (i / currentParams[&"width"])
	return Vector2i(x, y)

func updateVisualPosition(i: int):
	board[i].position = getPositionForIndex(i)

func generateNextFloor() -> void:
	depth = depth + 1
	if depth >= paramsList.size():
		win()
	for piece in board:
		if piece != null:
			remove_child(piece)
			if !players.has(piece):
				piece.queue_free()
	var params: Dictionary = paramsList[depth]
	board = generator.generateLevel(params)
	for piece in board:
		if piece != null:
			add_child(piece)
	#place players
	for player in players:
		add_child(player)
		player.gridIndex = player.gridIndex % currentParams[&"width"]
		board[player.gridIndex] = player

func win():
	emit_signal("exit")

func move(piece: Piece, toIndex: int):
	if board[toIndex] == null:
		board[piece.gridIndex] = null
		board[toIndex] = piece
		piece.gridIndex = toIndex
		updateVisualPosition(toIndex)

func fall(piece: Piece, pieceIndex: int, belowIndex: int):
	if piece.fastFall:
		piece.fallingCounter = piece.defaultFastFallCounter
	else:
		piece.fallingCounter = piece.defaultFallingCounter
	move(piece, belowIndex)
	#make stack above fall, if piece is in stack
	if(pieceIndex - currentParams[&"width"] >= 0 && board[pieceIndex - currentParams[&"width"]] != null):
		fall(board[pieceIndex - currentParams[&"width"]], pieceIndex - currentParams[&"width"], pieceIndex)

func handle_direction(player: Player, direction: Vector2i):
	pass #todo

func run_up(player: Player):
	pass

func _physics_process(delta: float) -> void:
	for i in range(board.size()):
		var piece: Piece = board[i]
		var belowIndex: int = i + currentParams[&"width"]
		if piece != null:
			#todo delay fall if player is moving under or away. If away, stack fall timer
			if belowIndex < board.size() && board[belowIndex] == null:
				piece.fallingCounter = piece.fallingCounter - delta
				if piece.fallingCounter <= 0:
					fall(piece, i, belowIndex)
			else:
				piece.fallingCounter = piece.defaultFallingCounter
				piece.fastFall = false
		if piece is Player:
			# walking
			var directionPressed: Vector2i = Vector2i(0,0)
			if Input.is_action_pressed("left"):
				directionPressed = directionPressed + Vector2i(-1,0)
			if Input.is_action_pressed("right"):
				directionPressed = directionPressed + Vector2i(1,0)
			if Input.is_action_pressed("up"):
				directionPressed = directionPressed + Vector2i(0,-1)
			if Input.is_action_pressed("down"):
				directionPressed = directionPressed + Vector2i(0,1)
			handle_direction(piece, directionPressed)
