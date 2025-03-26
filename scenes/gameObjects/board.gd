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

func fall(piece: Piece, pieceIndex: int, belowIndex: int, startingFallValue: float):
	# Player never falls fast.
	if !startingFallValue == piece.defaultFastFallCounter || !(piece is Player):
		piece.fallingCounter = startingFallValue
		move(piece, belowIndex)
		#make stack above fall, if piece is in stack
		if(pieceIndex - currentParams[&"width"] >= 0 && board[pieceIndex - currentParams[&"width"]] != null):
			fall(board[pieceIndex - currentParams[&"width"]], pieceIndex - currentParams[&"width"],
			pieceIndex, startingFallValue)

func handle_direction(player: Player, direction: Vector2i):
	if player.state == player.stateType.IDLE:
		#holding left or right
		if direction.x != 0:
			#holding backward
			if player.facing != direction.x:
				#turn around
				player.state = player.stateType.TURNING
				player.stateCountdown = player.defaultTurnaroundCounter
			#tile above is empty and we're holding into wall
			elif (player.gridIndex - currentParams[&"width"] >= 0
			&& board[player.gridIndex - currentParams[&"width"]] == null
			&& ((direction.x == -1 && (player.gridIndex % currentParams[&"width"] == 0
			|| board[player.gridIndex - 1] != null))
			|| (direction.x == 1
			&& ((player.gridIndex + 1) % currentParams[&"width"] == 0
			|| board[player.gridIndex + 1] != null)))):
				# climb
				player.climb_state()
			# we are holding forward into empty space, and are grounded
			elif (((direction.x == -1 && player.gridIndex % currentParams[&"width"] != 0
			&& board[player.gridIndex - 1] == null)
			|| (direction.x == 1 && (player.gridIndex + 1) % currentParams[&"width"] != 0
			&& board[player.gridIndex + 1] == null)) && player.vertically_centered()
			&& (player.gridIndex + currentParams[&"width"] >= board.size()
			|| board[player.gridIndex + currentParams[&"width"]] != null)):
				#walk
				player.state = player.stateType.WALKING
				player.stateCountdown = player.defaultWalkCounter
		# holding up
		elif direction.y == -1:
			#not on ceiling
			if player.gridIndex - currentParams[&"width"] >= 0:
				# no block above
				if board[player.gridIndex - currentParams[&"width"]] == null:
					# look in front for wall to climb
					if ((player.facing == -1 && (player.gridIndex % currentParams[&"width"] == 0
					|| board[player.gridIndex - 1] != null))
					|| (player.facing == 1
					&& ((player.gridIndex + 1) % currentParams[&"width"] == 0
					|| board[player.gridIndex + 1] != null))):
						player.climb_state()
				elif player.nonBufferedClimb:
					player.nonBufferedClimb = false
					# leap to top of stack
					# todo delay, maybe
					board[player.gridIndex] = null
					var target = player.gridIndex
					var above = player.gridIndex - currentParams[&"width"]
					while above >= 0 && board[above] != null:
						move(board[above], target)
						target = above
						above = above - currentParams[&"width"]
					board[target] = player
	elif player.state == player.stateType.CLIMBING:
		#if not holding up and holding horizonally neutral or backwards
		if (direction.y != -1 && (direction.x == 0 || direction.x != 0 && direction.x != player.facing)):
			player.idle_state() #idle for 1 frame, turn around next frame if conditions are right.
		# holding forward or up, but no block in front of us
		elif ((player.facing == -1 && (player.gridIndex % currentParams[&"width"] != 0
		&& board[player.gridIndex - 1] == null))
		|| (player.facing == 1
		&& ((player.gridIndex + 1) % currentParams[&"width"] != 0
		&& board[player.gridIndex + 1] == null))):
			var belowAndInFront = player.gridIndex + player.facing + currentParams[&"width"]
			# there is a piece by our feet
			if (belowAndInFront < board.size() && board[belowAndInFront] != null):
				# if at/above the center of the block, walk forward, otherwise keep climbing
				if player.above_vertically_centered():
					player.walk_state()
			# no piece by our feet. Fall
			else:
				player.idle_state()
		# holding forward or up and there is a block in front of us. Keep climbing (with some exceptions)
		else:
			player.stateCountdown = player.defaultWalkCounter
			if player.above_vertically_centered():
				# ceiling
				if player.gridIndex - currentParams[&"width"] < 0:
					#trot in place
					player.center()
				#piece landed on us
				elif board[player.gridIndex - currentParams[&"width"]] != null:
					player.idle_state()

func toggle_bomb(target: int):
	if (target >= 0 && board[target] != null && !(board[target] is Player)):
		#turn piece into bomb
		board[target].toggleBomb()
		#recurse whole stack
		toggle_bomb(target - currentParams[&"width"])

func handle_buffered_input(player: Player):
	if player.bufferedCycle:
		player.bufferedCycle = false
		#not climbing
		if player.state != player.stateType.CLIMBING:
			#toggle piece above
			toggle_bomb(player.gridIndex - currentParams[&"width"])
	if (player.state == player.stateType.IDLE || player.state == player.stateType.CLIMBING
	|| player.state == player.stateType.TURNING):
		if player.bufferedPickUpStack:
			pick_or_put(player, true)
		elif player.bufferedPickUpOne:
			pick_or_put(player, false)
		elif player.bufferedKick:
			player.bufferedKick = false

func pick_or_put(player: Player, stack: bool):
	player.bufferedPickUpStack = false
	player.bufferedPickUpOne = false
	player.bufferedKick = false
	if (player.gridIndex - currentParams[&"width"] >= 0
	&& board[player.gridIndex - currentParams[&"width"]] != null):
		# attempt placement
		if ((player.facing == -1 && player.gridIndex % currentParams[&"width"] != 0)
		|| (player.facing == 1 && (player.gridIndex + 1) % currentParams[&"width"] != 0)):
			var target = player.gridIndex + player.facing
			for i in range(3):
				if target >= 0 && board[target] == null:
					#placement of bottom piece successful
					var above = player.gridIndex - currentParams[&"width"] - currentParams[&"width"]
					if !stack:
						move(board[player.gridIndex - currentParams[&"width"]], target)
						if (above >= 0 && board[above] != null):
							# make rest of stack fall
							fall(board[above], above, player.gridIndex - currentParams[&"width"],
							player.defaultFastFallCounter)
					else:
						# test for rest of stack
						var passed = true
						var testTarget = target
						while above >= 0 && board[above] != null && !(board[above] is Player):
							testTarget = testTarget - 1
							#piece is occupying our target
							if testTarget < 0 || board[testTarget] != null:
								passed = false
								break
							above = above - currentParams[&"width"]
						if passed:
							#move whole stack
							above = player.gridIndex - currentParams[&"width"]
							while above >= 0 && board[above] != null && !(board[above] is Player):
								move(board[above], target)
								above = above - currentParams[&"width"]
								target = target - currentParams[&"width"]
					break
				# try next cell up
				target = target - currentParams[&"width"]
	else:
		player.grabbing_state(stack)

func handle_player_state(player: Player, delta: float):
	if player.state == player.stateType.TURNING:
		if player.stateCountdown == player.defaultTurnaroundCounter:
			player.turn_around()
	elif player.state == player.stateType.WALKING:
		# todo make stack have smooth movement too
		if player.walk(tilePixels, delta):
			# cross tile boundary
			move(player, player.gridIndex + player.facing)
			var aboveIndex: int = player.gridIndex - player.facing - currentParams[&"width"]
			while (aboveIndex >= 0 && board[aboveIndex] != null
			&& board[aboveIndex + player.facing] == null):
				# Bring stack too
				move(board[aboveIndex], aboveIndex + player.facing)
	elif player.state == player.stateType.CLIMBING:
		if player.climb(tilePixels, delta):
			# cross tile boundary
			move(player, player.gridIndex - currentParams[&"width"])
	player.stateCountdown = player.stateCountdown - delta
	if player.stateCountdown <= 0:
		#todo attempt grab
		if player.state == player.stateType.GRABBING_ONE:
			pass
		elif player.state == player.stateType.GRABBING_STACK:
			pass
		player.idle_state()

func checkSurroundingCellsForFall(fallTarget: int) -> bool:
	#return true if piece is good to fall into the target, false otherwise
	var left: int = fallTarget - 1
	var right: int = fallTarget + 1
	var down: int = fallTarget + currentParams[&"width"]
	# left
	return ((fallTarget % currentParams[&"width"] == 0 || board[left] == null || !board[left].off_center(1))
	# right
	&& (right % currentParams[&"width"] == 0 || board[right] == null || !board[right].off_center(-1))
	# below
	&& (down >= board.size() || board[down] == null
	|| (!board[down].off_center(0) && !(board[down] is Player
	&& (board[down].state == board[down].stateType.GRABBING_ONE
	|| board[down].state == board[down].stateType.GRABBING_STACK)))))

func _physics_process(delta: float) -> void:
	var directionPressed: Vector2i = Vector2i(0,0)
	if Input.is_action_pressed("left"):
		directionPressed = directionPressed + Vector2i(-1,0)
	if Input.is_action_pressed("right"):
		directionPressed = directionPressed + Vector2i(1,0)
	if Input.is_action_pressed("up"):
		directionPressed = directionPressed + Vector2i(0,-1)
	if Input.is_action_pressed("down"):
		directionPressed = directionPressed + Vector2i(0,1)
	handle_direction(players[0], directionPressed)
	handle_buffered_input(players[0])
	handle_player_state(players[0], delta)
	for i in range(board.size()):
		var piece: Piece = board[i]
		var belowIndex: int = i + currentParams[&"width"]
		if piece != null:
			if (belowIndex < board.size() && board[belowIndex] == null
			&& !(piece is Player && (piece.state == piece.stateType.CLIMBING
			|| piece.state == piece.stateType.WALKING))):
				#player smooth fall + inherit climbing position
				if piece is Player:
					if piece.fall(tilePixels, delta, false):
						fall(piece, i, belowIndex, piece.defaultFallingCounter)
				else:
					piece.fallingCounter = piece.fallingCounter - delta
					#todo delay fall if player is moving under or away.
					if piece.fallingCounter <= 0 && checkSurroundingCellsForFall(belowIndex):
						#Fall, and carry over fall timer if stacked because of player movement or dropped frames
						var nextFall: float = piece.fallingCounter
						if piece.fastFall:
							nextFall = nextFall + piece.defaultFastFallCounter
						else:
							nextFall = nextFall + piece.defaultFallingCounter
						fall(piece, i, belowIndex, nextFall)
			else:
				piece.fallingCounter = piece.defaultFallingCounter
				piece.fastFall = false
				if (piece is Player && piece.state != piece.stateType.CLIMBING
				&& piece.state != piece.stateType.WALKING && (belowIndex >= board.size()
				|| board[belowIndex] != null)):
					piece.fall(tilePixels, delta, true)
