extends Node2D
class_name Board

signal finished
signal won
signal collect_air(airContent: float, maxAir: float)
signal destroy_clock(airContent: float, maxAir: float)
signal all_clear
signal next_floor
signal hatch(doorIndex: int)

var hatchTimer: Timer
var chainTimer: Timer
var chainsEnabled: bool = false
var Omni = preload("res://scenes/gameObjects/pieces/Omni.tscn")
var Diag = preload("res://scenes/gameObjects/pieces/Diag.tscn")
var Player = preload("res://scenes/gameObjects/player.tscn")
var Lightning = preload("res://scenes/gameObjects/vfx/Lightning.tscn")
var Fire = preload("res://scenes/gameObjects/vfx/Fire.tscn")
var TimeJuice = preload("res://scenes/gameObjects/vfx/TimeJuice.tscn")
var sounds: Dictionary = {
	&"ice": preload("res://assets/sfx/steam hisses - Marker #5.wav"),
	&"charge": preload("res://assets/sfx/charge.mp3"),
	&"fuse": preload("res://assets/sfx/Waving Torch.ogg"),
	&"clear": preload("res://assets/sfx/clear.ogg"),
	&"fire": preload("res://assets/sfx/atari_fire_1.wav"),
	&"lightning": preload("res://assets/sfx/LightningStrike.ogg"),
	&"clock": preload("res://assets/sfx/clock-1.ogg"),
	&"creak": preload("res://assets/sfx/door_creak_open.ogg")
}
var sfx: Array[AudioStreamPlayer] = []
var Hint = preload("res://scenes/gameObjects/vfx/Hint.tscn")
var hints: Array[Hint] = []
var generator: Generator = Generator.new()
var players: Array[Player] = []
var depth: int = -1
var board: Array
var tilePixels: int = 32
# airHeight is 1-indexed from the bottom of the stack
var paramsList: Array[Dictionary] = [
	{&"width": 7, &"height": 7, &"buffer": 4, &"types": [Omni], &"colors": 6,
	&"airHeight": 4, &"airContent": 40.0, &"maxAir": 99.99, &"rain": 5.0},
	{&"width": 7, &"height": 7, &"buffer": 4, &"types": [Diag], &"colors": 6,
 	&"airHeight": 4, &"airContent": 40.0, &"maxAir": 99.99, &"rain": 5.0},
	{&"width": 7, &"height": 7, &"buffer": 4, &"types": [Omni, Diag], &"colors": 3,
	&"airHeight": 4, &"airContent": 40.0, &"maxAir": 99.99, &"rain": 5.0},
	{&"width": 7, &"height": 7, &"buffer": 4, &"types": [Diag], &"colors": 5,
	&"airHeight": 2, &"airContent": 40.0, &"maxAir": 99.99, &"rain": 5.0, &"spireHeight": 4},
	{&"width": 7, &"height": 7, &"buffer": 4, &"types": [Omni], &"colors": 5,
	&"airHeight": 3, &"airContent": 40.0, &"maxAir": 99.99, &"rain": 5.0},
	{&"width": 7, &"height": 7, &"buffer": 4, &"types": [Diag], &"colors": 3,
	&"airHeight": 2, &"airContent": 40.0, &"maxAir": 99.99, &"rain": 5.0},
	{&"width": 7, &"height": 7, &"buffer": 4, &"types": [Omni], &"colors": 3,
	&"airHeight": 3, &"airContent": 40.0, &"maxAir": 99.99, &"rain": 5.0, &"iceRow": 4},
	{&"width": 7, &"height": 7, &"buffer": 4, &"types": [Diag], &"colors": 2,
	&"airHeight": 2, &"airContent": 40.0, &"maxAir": 99.99, &"rain": 5.0},
	{&"width": 7, &"height": 7, &"buffer": 4, &"types": [Omni], &"colors": 2,
	&"airHeight": 6, &"airContent": 40.0, &"maxAir": 99.99, &"rain": 5.0},
	{&"width": 7, &"height": 7, &"buffer": 4, &"types": [Omni, Diag], &"colors": 1,
	&"airHeight": 3, &"airContent": 40.0, &"maxAir": 99.99, &"rain": 5.0},
	{&"width": 7, &"height": 7, &"buffer": 4, &"types": [Omni], &"colors": 4,
	&"airHeight": 5, &"airContent": 40.0, &"maxAir": 99.99, &"rain": 5.0},
	{&"width": 7, &"height": 7, &"buffer": 4, &"types": [Omni,Diag], &"colors": 2,
	&"airHeight": 5, &"airContent": 40.0, &"maxAir": 99.99, &"rain": 5.0},
	{&"width": 7, &"height": 7, &"buffer": 4, &"types": [Diag], &"colors": 4,
	&"airHeight": 5, &"airContent": 40.0, &"maxAir": 99.99, &"rain": 5.0}
]
var currentParams: Dictionary = paramsList[depth + 1]
var secondsElapsed: float = 0.0
var rainCounter: float = 5.0
var typesOfMonster: Array[Array] = []
var animating: int = 0
var allClearHappened: bool = false
var pickupTimer: Timer
var clockTimer: Timer

func _ready() -> void:
	clockTimer = Timer.new()
	clockTimer.one_shot = true
	clockTimer.autostart = false
	clockTimer.timeout.connect(_on_clockTimer_timeout)
	add_child(clockTimer)
	hatchTimer = Timer.new()
	hatchTimer.wait_time = 0.5
	hatchTimer.autostart = false
	hatchTimer.one_shot = true
	hatchTimer.timeout.connect(generateNextFloor)
	add_child(hatchTimer)
	chainTimer = Timer.new()
	chainTimer.wait_time = 0.76
	chainTimer.autostart = false
	chainTimer.one_shot = true
	add_child(chainTimer)
	for i in range(10):
		sfx.append(AudioStreamPlayer.new())
		sfx[sfx.size() - 1].set_bus("sfx")
		add_child(sfx[sfx.size() - 1])
	players.append(Player.instantiate())
	for playerNum in range(players.size()):
		add_child(players[playerNum])
		# evenly distribute the players
		players[playerNum].gridIndex = (currentParams[&"width"] * (playerNum + 1)) / (players.size() * 2)
	generateNextFloor()
	pause_clock_for(1.0)
	for i in range(currentParams[&"width"]):
		hints.append(Hint.instantiate())
		hints[hints.size() - 1].position = getPositionForIndex(board.size() + i)
		add_child(hints[hints.size() - 1])
	pickupTimer = Timer.new()
	pickupTimer.wait_time = 8.0
	pickupTimer.autostart = true
	pickupTimer.one_shot = false
	pickupTimer.timeout.connect(showHint)
	add_child(pickupTimer)
	if depth != 10 || get_parent().get_parent().graduated:
		pickupTimer.paused = true

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

func showHint():
	for i in range(currentParams[&"width"]):
		if ((board[board.size() - currentParams[&"width"] + i] == null
		|| (board[board.size() - currentParams[&"width"] + i] is Player))
		&& ((board[board.size() - 2*currentParams[&"width"] + i] == null
		|| (board[board.size() - 2*currentParams[&"width"] + i] is Player)))):
			#bottom two cells of column are empty
			if i != 0:
				hints[i - 1].animate()
			if i < hints.size() - 1:
				hints[i + 1].animate()

func pause_clock_for(time: float):
	clockTimer.start(time)

func _on_clockTimer_timeout():
	for piece in board:
		if piece != null && piece is Air:
			piece.tick_tock()

func generateNextFloor() -> void:
	if pickupTimer != null:
		pickupTimer.paused = true
	depth = depth + 1
	if depth >= paramsList.size():
		for piece in board:
			if piece != null && !(piece is Player):
				piece.queue_free()
		board = generator.victory(players[0].gridIndex % currentParams[&"width"], [Omni, Diag],
		currentParams[&"height"] + currentParams[&"buffer"], currentParams[&"width"])
		for piece in board:
			if piece != null:
				piece.process_mode = Node.PROCESS_MODE_ALWAYS
				add_child(piece)
				piece.win("")
		for player in players:
			# remove and add to change processing order to last
			remove_child(player)
			add_child(player)
			player.gridIndex = player.gridIndex % currentParams[&"width"]
			board[player.gridIndex] = player
		updateVisualPositions()
		win()
	else:
		for piece in board:
			if piece != null && !(piece is Player):
				piece.queue_free()
		currentParams = paramsList[depth]
		board = generator.generateLevel(currentParams)
		for piece in board:
			if piece != null:
				add_child(piece)
				if !typesOfMonster.has([piece.variety, piece.type]) && !(piece is Air):
					typesOfMonster.append([piece.variety, piece.type])
		dance()
		#place players
		for player in players:
			# remove and add to change processing order to last
			remove_child(player)
			add_child(player)
			player.gridIndex = player.gridIndex % currentParams[&"width"]
			board[player.gridIndex] = player
		updateVisualPositions()
		if currentParams.has(&"rain"):
			rainCounter = currentParams[&"rain"]
		emit_signal("next_floor")
	allClearHappened = false

func dance():
	if animating >= typesOfMonster.size():
		animating = 0
	for piece in board:
		if (piece != null && !(piece is Air) && ! piece.ice && piece.type == typesOfMonster[animating][1]
		&& piece.variety == typesOfMonster[animating][0]):
			piece.animate()
	animating = animating + 1

func win():
	emit_signal("won")

func lose():
	emit_signal("finished")

func play_sfx(key: StringName):
	var played: bool = false
	var replace: AudioStreamPlayer
	var score: float = -1.0
	for player in sfx:
		if !player.playing:
			player.stream = sounds[key]
			player.play()
			played = true
			break
		else:
			var test = player.get_playback_position()
			if test > score:
				score = test
				replace = player
	if !played:
		replace.stop()
		replace.stream = sounds[key]
		replace.play

func move(piece: Piece, toIndex: int):
	#var fromIndex = piece.gridIndex
	if board[toIndex] == null:
		board[piece.gridIndex] = null
		board[toIndex] = piece
		piece.gridIndex = toIndex
		updateVisualPosition(toIndex)

func fall(piece: Piece, pieceIndex: int, belowIndex: int, startingFallValue: float):
	# Player never falls fast.
	if startingFallValue > piece.defaultFastFallCounter || !(piece is Player):
		piece.fallingCounter = startingFallValue
		move(piece, belowIndex)
		#make stack above fall, if piece is in stack
		if(pieceIndex - currentParams[&"width"] >= 0 && board[pieceIndex - currentParams[&"width"]] != null
		&& !(board[pieceIndex - currentParams[&"width"]] is Player)):
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
				player.walk_state()
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
						board[target].fall_fast()
						target = above
						above = above - currentParams[&"width"]
					player.gridIndex = target #set index early, still call move for other updates
					move(player, target)
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
					#todo do this same thing when player didn't climb into the piece
					board[player.gridIndex - currentParams[&"width"]].set_bomb(secondsElapsed)

func toggle_bomb(target: int):
	if (target >= 0 && board[target] != null && !(board[target] is Player)):
		#turn piece into bomb
		board[target].toggle_bomb(secondsElapsed)
		#recurse whole stack
		#toggle_bomb(target - currentParams[&"width"])

func handle_buffered_input(player: Player):
	if (player.bufferedCycle && player.state != player.stateType.GRABBING_ONE
	&& player.state != player.stateType.GRABBING_STACK):
		player.bufferedCycle = false
		#not climbing
		if player.state != player.stateType.CLIMBING:
			#toggle piece above
			toggle_bomb(player.gridIndex - currentParams[&"width"])
	if (player.state == player.stateType.IDLE || player.state == player.stateType.CLIMBING
	|| player.state == player.stateType.TURNING):
		if player.bufferedPickUpStack:
			pick_or_put(player, true, false)
		elif player.bufferedPickUpOne:
			pick_or_put(player, false, false)
		elif player.bufferedKick:
			player.bufferedKick = false
			player.is_this_the_part_where_we_start_kicking()

func downTheHatch():
	play_sfx(&"creak")
	#open hatch
	emit_signal("hatch", (players[0].gridIndex + players[0].facing) % currentParams[&"width"])
	hatchTimer.start()
	get_parent().get_parent().graduated = true

func pick_or_put(player: Player, stack: bool, pick: bool):
	var overhead: int = player.gridIndex - currentParams[&"width"]
	var front: int = player.gridIndex + player.facing
	if front < board.size():
		# backup spots: down for pick, up for put
		if pick && board[front] == null:
			front = front + currentParams[&"width"]
		elif !pick && board[front] != null:
			for i in range(2):
				front = front - currentParams[&"width"]
				if front >= 0 && board[front] == null:
					break
	# pick source is front and target is above
	var source: int = front
	var target: int = overhead
	if !pick:
		# flip source and target
		source = overhead
		target = front
		# clear buffer (we are activating it now)
		player.bufferedPickUpStack = false
		player.bufferedPickUpOne = false
		player.bufferedKick = false
	if !pick && (overhead < 0 || board[overhead] == null):
		#nothing overhead. Initiate pick.
		player.grabbing_state(stack)
	#overhead is in bounds
	elif (overhead >= 0
	#player is not facing wall
	&& ((player.facing == -1 && player.gridIndex % currentParams[&"width"] != 0)
	|| (player.facing == 1 && (player.gridIndex + 1) % currentParams[&"width"] != 0))):
		if source >= board.size():
			#down the match
			downTheHatch()
		# first piece can move successfully
		elif (board[source] != null && board[target] == null && !board[source].ice):
			var above = source - currentParams[&"width"]
			if board[source] is Air && pick:
				pickupTimer.start()
				play_sfx(&"clock")
				var juice = TimeJuice.instantiate()
				juice.get_node("Label").text = "+40"
				juice.position = getPositionForIndex(source)
				add_child(juice)
				board[source].queue_free()
				board[source] = null
				emit_signal("collect_air", currentParams[&"airContent"], currentParams[&"maxAir"])
			elif !stack:
				#perform move
				move(board[source], target)
				board[target].fall_fast()
				if !pick:
					player.put_down_animation()
				var coyoteIndex = source - currentParams[&"width"]
				while (pick && coyoteIndex >= 0 && board[coyoteIndex] != null
				&& !board[coyoteIndex] is Player):
					board[coyoteIndex].coyoteTime = 1
					coyoteIndex = coyoteIndex - currentParams[&"width"]
				# there is a stack and we are putting
				if (above >= 0 && board[above] != null && !pick):
					# make rest of stack fall
					fall(board[above], above, source, player.defaultFastFallCounter)
			else:
				# test rest of stack
				var passed = true
				var testTarget = target
				while above >= 0 && board[above] != null && !board[above] is Player && !board[above].ice:
					testTarget = testTarget - currentParams[&"width"]
					#target out of bounds or piece is occupying our target
					if testTarget < 0 || board[testTarget] != null:
						passed = false
						break
					above = above - currentParams[&"width"]
				if passed:
					#move whole stack
					above = source
					while (above >= 0 && board[above] != null && !(board[above] is Player)
					&& !board[above].ice):
						move(board[above], target)
						board[target].fall_fast()
						above = above - currentParams[&"width"]
						target = target - currentParams[&"width"]
					if !pick:
						player.put_down_animation()

func handle_player_state(player: Player, delta: float):
	if player.state == player.stateType.TURNING:
		if player.stateCountdown == player.defaultTurnaroundCounter:
			player.turn_around()
	elif player.state == player.stateType.WALKING:
		# todo have falling check scan down for player
		# (but if not it will just knock off the top of the stack it's fine)
		if player.walk(tilePixels, delta):
			# cross tile boundary
			move(player, player.gridIndex + player.facing)
			var aboveIndex: int = player.gridIndex - player.facing - currentParams[&"width"]
			while (aboveIndex >= 0 && board[aboveIndex] != null
			&& board[aboveIndex + player.facing] == null && ! board[aboveIndex].ice):
				# Bring stack too
				move(board[aboveIndex], aboveIndex + player.facing)
				aboveIndex = aboveIndex - currentParams[&"width"]
	elif player.state == player.stateType.CLIMBING:
		if player.climb(tilePixels, delta):
			# cross tile boundary
			move(player, player.gridIndex - currentParams[&"width"])
	elif (player.state == player.stateType.KICKING && !player.didAKick
	&& player.stateCountdown <= player.kickPoint
	&& !(player.facing == -1 && player.gridIndex % currentParams[&"width"] == 0)
	&& !(player.facing == 1 && (player.gridIndex + 1) % currentParams[&"width"] == 0)
	&& board[player.gridIndex + player.facing] != null):
		board[player.gridIndex + player.facing].kick(player.facing)
		player.didAKick = true
	player.stateCountdown = player.stateCountdown - delta
	if player.stateCountdown <= 0:
		#attempt grab
		if player.state == player.stateType.GRABBING_ONE:
			pick_or_put(player, false, true)
		elif player.state == player.stateType.GRABBING_STACK:
			pick_or_put(player, true, true)
		player.idle_state()
		var above: int = player.gridIndex - currentParams[&"width"]
		if above >= 0 && board[above] != null:
			board[above].set_bomb(secondsElapsed)

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

func check_stable(cell: int, ignoreKicked: bool) -> bool:
	if board[cell] == null || (!ignoreKicked && board[cell].kicked != 0):
		return false
	elif board[cell].coyoteTime >= 0:
		return true
	var stable = true
	var ground = cell + currentParams[&"width"]
	while ground < board.size():
		if board[ground] == null:
			stable = false
			break
		elif board[ground] is Player:
			break
		ground = ground + currentParams[&"width"]
	return stable

func check_clears():
	var clearDicts: Array[Dictionary] = []
	for cell in range(board.size()):
		if board[cell] != null && board[cell].bomb:
			#check for stability
			if check_stable(cell, false):
				#check for matches in the directions in which this piece can match
				var clears: Array[int] = []
				var breakfast: bool = false
				var largestClear: int = 0
				for vector in board[cell].matchVecs:
					var matches = get_matches_in_direction(cell, vector)
					# check opposite direction (only half of the directions are listed by design)
					matches.append_array(get_matches_in_direction(cell, vector * -1))
					# 3 pieces including current piece
					if matches.size() >= 2:
						# We will clear this line. Check for breakfast too
						if clears.size() > 0:
							breakfast = true
						clears.append_array(matches)
						clears.append(cell)
						largestClear = max(largestClear, matches.size() + 1)
				#look through existing clears this frame
				var modified: bool = false
				var duplicate: bool = false
				for dict in clearDicts:
					#piggyback existing clear, if exists
					var has: bool = false
					var hasNot: bool = false
					for i in clears:
						if dict[&"cells"].has(i):
							has = true
						else:
							hasNot = true
					if has:
						duplicate = true
						if hasNot:
							duplicate = false
							#combine these clears
							dict[&"breakfast"] = true
							dict[&"size"]= max(largestClear, dict[&"size"])
							for i in clears:
								dict[&"cells"][i] = true
							modified = true
						#break #could be okay but the benefit is marginal, so why risk it
				if !modified && !duplicate && !clears.is_empty():
					# new clear
					var dict: Dictionary = {&"size": largestClear, &"breakfast": breakfast, &"cells": {}}
					for i in clears:
						dict[&"cells"][i] = true
					clearDicts.append(dict)
	clear(clearDicts)

func clear(clearDicts: Array[Dictionary]):
	#additional consequences based on clear size/type
	var cellsToClear: Dictionary[int,bool] = {}
	var cellsToPreserve: Dictionary[int,int] = {}
	for dict in clearDicts:
		var latestBomb: int
		var time: float = 0.0
		for cell in dict[&"cells"]:
			if board[cell].bombCreationTime >= time:
				time = board[cell].bombCreationTime
				latestBomb = cell
		for cell in dict[&"cells"]:
			cellsToClear[cell] = true
			if cell == latestBomb && (dict[&"breakfast"] || dict[&"size"] > 3):
				if dict[&"breakfast"] && dict[&"size"] > 3:
					cellsToPreserve[cell] = 3
				elif(dict[&"breakfast"]):
					cellsToPreserve[cell] = 2
				elif(dict[&"size"] > 3):
					cellsToPreserve[cell] = 1
	# Actually clear
	if !cellsToClear.is_empty():
		pickupTimer.start()
		play_sfx(&"clear")
		if chainTimer.is_stopped():
			chainTimer.start()
		elif chainsEnabled:
			chainTimer.start()
			play_sfx(&"clock")
			var juice = TimeJuice.instantiate()
			juice.get_node("Label").text = "+1"
			juice.position = getPositionForIndex(cellsToClear[0])
			add_child(juice)
			emit_signal("collect_air", 1.0, currentParams[&"maxAir"])
	var alreadyCleared: Array[int] = []
	while !cellsToClear.is_empty():
		var cell = cellsToClear.keys()[0]
		if board[cell] != null && !alreadyCleared.has(cell):
			#activate flame/lightning
			if board[cell].lightning:
				play_sfx(&"lightning")
				var light = Lightning.instantiate()
				light.position = getPositionForIndex(cell)
				add_child(light)
				#left
				var scan: int = cell - 1
				var left = 0
				while (scan + 1) % currentParams[&"width"] != 0:
					cellsToClear[scan] = true
					if board[scan] != null && board[scan].ice:
						break
					scan = scan - 1
					left = left + 1
				#right
				scan = cell + 1
				var right = 0
				while scan % currentParams[&"width"] != 0:
					cellsToClear[scan] = true
					if board[scan] != null && board[scan].ice:
						break
					scan = scan + 1
					right = right + 1
				#up
				scan = cell - currentParams[&"width"]
				var up = 0
				while scan >= 0:
					cellsToClear[scan] = true
					if board[scan] != null && board[scan].ice:
						break
					scan = scan - currentParams[&"width"]
					up = up + 1
				#down
				scan = cell + currentParams[&"width"]
				var down = 0
				while scan < board.size():
					cellsToClear[scan] = true
					if board[scan] != null && board[scan].ice:
						break
					scan = scan + currentParams[&"width"]
					down = down + 1
				light.set_length(left,right,up,down)
			if board[cell].flame:
				play_sfx(&"fire")
				var f = Fire.instantiate()
				f.position = getPositionForIndex(cell)
				add_child(f)
				var onLeftWall: bool = cell % currentParams[&"width"] == 0
				var onRightWall: bool = (cell + 1) % currentParams[&"width"] == 0
				var onCeiling: bool = cell - currentParams[&"width"] < 0
				var onFloor: bool = cell + currentParams[&"width"] >= board.size()
				if !onLeftWall:
					cellsToClear[cell - 1] = true
					if !onFloor:
						cellsToClear[cell - 1 + currentParams[&"width"]] = true
					if !onCeiling:
						cellsToClear[cell - 1 - currentParams[&"width"]] = true
				if !onRightWall:
					cellsToClear[cell + 1] = true
					if !onFloor:
						cellsToClear[cell + 1 + currentParams[&"width"]] = true
					if !onCeiling:
						cellsToClear[cell + 1 - currentParams[&"width"]] = true
				if !onCeiling:
					cellsToClear[cell - currentParams[&"width"]] = true
				if !onFloor:
					cellsToClear[cell + currentParams[&"width"]] = true
			if !cellsToPreserve.has(cell):
				clear_cell(cell)
			else:
				alreadyCleared.append(cell)
				board[cell].revert_special()
				if cellsToPreserve[cell] == 1:
					play_sfx(&"fuse")
					board[cell].set_flame(4)
				elif cellsToPreserve[cell] == 2:
					play_sfx(&"charge")
					board[cell].set_lightning()
				elif cellsToPreserve[cell] == 3:
					play_sfx(&"fuse")
					play_sfx(&"charge")
					board[cell].set_flame(4)
					board[cell].set_lightning()
		cellsToClear.erase(cell)
	if !allClearHappened:
		var allClear: bool = true
		for cell in board:
			if cell != null && !(cell is Player):
				allClear = false
				break
		if allClear:
			emit_signal("all_clear")
			allClearHappened = true
			play_sfx(&"clock")
			var juice = TimeJuice.instantiate()
			juice.get_node("Label").text = "+10"
			juice.position = getPositionForIndex(max(0, players[0].gridIndex - currentParams[&"width"]))
			add_child(juice)
			emit_signal("collect_air", currentParams[&"airContent"] / 4, currentParams[&"maxAir"])

func clear_cell(cell: int) -> void:
	if board[cell] != null:
		if board[cell] is Player:
			lose()
		elif board[cell].ice:
			play_sfx(&"ice")
			board[cell].melt_ice()
		else:
			if board[cell] is Air:
				play_sfx(&"clock")
				var juice = TimeJuice.instantiate()
				juice.get_node("Label").text = "+20"
				juice.position = getPositionForIndex(cell)
				add_child(juice)
				emit_signal("destroy_clock", currentParams[&"airContent"], currentParams[&"maxAir"])
				board[cell].queue_free()
			else:
				board[cell].clear()
			board[cell] = null

func get_matches_in_direction(cell: int, vector: Vector2i) -> Array[int]:
	# does not cross a left/right board boundary
	if (vector.x == 0 || !((vector.x == -1 && cell % currentParams[&"width"] == 0) 
	|| (vector.x == 1 && (cell + 1) % currentParams[&"width"] == 0))):
		var testCell: int = cell + vector.x + vector.y * currentParams[&"width"]
		#not out of bounds above or below 
		if testCell < board.size() && testCell >= 0:
			# It's a match made in heaven!
			if board[testCell] != null && board[testCell].matches(board[cell]) && check_stable(testCell, false):
				# Keep checking that direction and return all matches together
				var result: Array[int] = get_matches_in_direction(testCell, vector)
				result.append(testCell)
				return result
	# Base case: no match
	return []

func _physics_process(delta: float) -> void:
	if hatchTimer.is_stopped():
		var animating: bool = false
		for piece in board:
			if (piece != null && !(piece is Air) && !(piece is Player)
			&& piece.get_node("AnimationPlayer").current_animation != null
			&& piece.get_node("AnimationPlayer").current_animation != ""
			&& piece.get_node("AnimationPlayer").current_animation != "clear"):
				var anim = piece.get_node("AnimationPlayer").current_animation
				animating = true
				break
		if !animating:
			dance()
		check_clears()
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
		if currentParams.has(&"rain"):
			rainCounter = rainCounter - delta
			if rainCounter <= 0.0:
				rainCounter = currentParams[&"rain"]
				var options: Array = []
				for i in range(currentParams[&"width"]):
					if board[i] == null:
						options.append(i)
				if options.is_empty():
					lose()
				else:
					var target = options[randi_range(0, options.size() - 1)]
					var types: Dictionary[Array, bool] = {}
					for i in range(board.size()):
						if board[i] != null && !(board[i] is Player) && !(board[i] is Air):
							types[[board[i].type, board[i].variety]] = true
					if !types.is_empty():
						var result = types.keys()[randi_range(0, types.keys().size() - 1)]
						var rain
						for mon in currentParams[&"types"]:
							rain = mon.instantiate()
							add_child(rain)
							if rain.variety == result[1]:
								break
							else:
								remove_child(rain)
								rain.queue_free()
						rain.set_type(result[0])
						rain.gridIndex = target
						move(rain, target)
		for i in range(board.size()):
			var piece: Piece = board[i]
			var belowIndex: int = i + currentParams[&"width"]
			if piece != null:
				if piece.coyoteTime >= 0:
					piece.coyoteTime = piece.coyoteTime - 1
				if piece.kicked != 0:
					var target: int = i + piece.kicked
					if (!(piece.kicked == -1 && i % currentParams[&"width"] == 0)
					&& !(piece.kicked == 1 && (i + 1) % currentParams[&"width"] == 0)
					&& board[target] == null && check_stable(i, true)):
						piece.stateCountdown = piece.stateCountdown - delta
						if piece.stateCountdown <= 0:
							move(piece, target)
							piece.stateCountdown = piece.defaultSlideCounter
					else:
						piece.bonk()
				if (belowIndex < board.size() && board[belowIndex] == null
				&& !(piece is Player && (piece.state == piece.stateType.CLIMBING
				|| piece.state == piece.stateType.WALKING))):
					#player smooth fall + inherit climbing position
					if piece is Player:
						if piece.fall(tilePixels, delta, false):
							fall(piece, i, belowIndex, piece.defaultFallingCounter)
					else:
						piece.fallingCounter = piece.fallingCounter - delta
						#delay fall if player is moving under or away.
						if piece.fallingCounter <= 0 && checkSurroundingCellsForFall(belowIndex):
							#Fall, and carry over fall timer if stacked because of player movement
							# or dropped frames
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
		secondsElapsed = secondsElapsed + delta

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("another") && rainCounter < currentParams[&"rain"] - 0.1:
		var free = false
		for i in range(currentParams[&"width"]):
			if board[i] == null:
				free = true
				break
		if free:
			rainCounter = 0
