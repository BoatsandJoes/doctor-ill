extends Object
class_name Generator

var Air = preload("res://scenes/gameObjects/pieces/Air.tscn")

func victory(playerCol: int, types: Array, height: int, width: int) -> Array:
	var result: Array = []
	for i in range(height - types.size()):
		for j in range(width):
			result.append(null)
	for j in range(types.size() - 1, -1, -1):
		var type = types[j]
		for i in range(width):
			if i == playerCol:
				result.append(null)
			else:
				result.append(type.instantiate())
				if i < playerCol:
					result[result.size() - 1].set_type(i)
				else:
					result[result.size() - 1].set_type(i - 1)
	return result

func generateLevel(params: Dictionary) -> Array:
	var result: Array = []
	var bag: Array = []
	var monCount: int = (params[&"height"] * params[&"width"]) - 1 # 1 is clock
	if params.has(&"spireHeight"):
		monCount = monCount - 3 * params[&"spireHeight"]
	var numEachMonster = monCount / params[&"types"].size()
	if monCount % params[&"types"].size() != 0:
		numEachMonster = numEachMonster + 1
	for typeIndex in range(params[&"types"].size()):
		for i in range(numEachMonster):
			var monster: Piece = params[&"types"][typeIndex].instantiate()
			monster.set_type(i % params[&"colors"])
			bag.append(monster)
	for rowIndex in range(params[&"buffer"]):
		for colIndex in range(params[&"width"]):
			result.append(null)
	var airIndex: int = -1
	for rowIndex in range(params[&"height"]):
		var airColIndex = -1
		if rowIndex + params[&"airHeight"] == params[&"height"]:
			var options = [1, params[&"width"] - 2]
			airColIndex = options[randi_range(0, options.size() - 1)]
		for colIndex in range(params[&"width"]):
			if colIndex == airColIndex:
				#place air
				result.append(Air.instantiate())
				airIndex = result.size() - 1
				result[result.size() - 1].gridIndex = result.size() - 1
			elif params.has(&"spireHeight") && params[&"spireHeight"] > rowIndex && colIndex % 2 != 0:
				result.append(null)
			else:
				var bagIndex: int = randi_range(0, bag.size() - 1)
				result.append(bag[bagIndex])
				bag.remove_at(bagIndex)
				result[result.size() - 1].gridIndex = result.size() - 1
				if params.has("bomb"):
					result[result.size() - 1].set_bomb(0) 
	#place garbage
	if params.has(&"iceRow"):
		var start: int = result.size() - params[&"iceRow"] * params[&"width"]
		for i in range(start, start + params[&"width"]):
			if result[i] != null:
				result[i].set_ice()
	elif params.has(&"airHeight"):
		var onLeftWall: bool = airIndex % params[&"width"] == 0
		var onRightWall: bool = (airIndex + 1) % params[&"width"] == 0
		var onCeiling: bool = airIndex - params[&"width"] < 0
		var onFloor: bool = airIndex + params[&"width"] >= result.size()
		if !onLeftWall:
			if result[airIndex - 1] != null:
				result[airIndex - 1].set_ice()
			if !onCeiling && result[airIndex - 1 - params[&"width"]] != null:
				result[airIndex - 1 - params[&"width"]].set_ice()
			if !onFloor && result[airIndex - 1 + params[&"width"]] != null:
				result[airIndex - 1 + params[&"width"]].set_ice()
		if !onRightWall:
			if result[airIndex + 1] != null:
				result[airIndex + 1].set_ice()
			if !onCeiling && result[airIndex + 1 - params[&"width"]] != null:
				result[airIndex + 1 - params[&"width"]].set_ice()
			if !onFloor && result[airIndex + 1 + params[&"width"]] != null:
				result[airIndex + 1 + params[&"width"]].set_ice()
		if !onCeiling:
			if result[airIndex - params[&"width"]] != null:
				result[airIndex - params[&"width"]].set_ice()
		if !onFloor:
			if result[airIndex + params[&"width"]] != null:
				result[airIndex + params[&"width"]].set_ice()
	return result
