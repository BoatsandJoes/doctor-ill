extends Object
class_name Generator

var Air = preload("res://scenes/gameObjects/pieces/Air.tscn")

func generateLevel(params: Dictionary) -> Array:
	var result: Array = []
	var bag: Array = []
	var monCount: int = (params[&"height"] * params[&"width"]) - 1
	var numEachMonster = monCount / params[&"types"].size()
	if monCount % params[&"types"].size() != 0:
		numEachMonster = numEachMonster + 1
	for typeIndex in range(params[&"types"].size()):
		for i in range(numEachMonster):
			var monster: Piece = params[&"types"][typeIndex].instantiate()
			#todo use distinct colors if there are two instances of the same monster type
			# (maybe change input format to take a different number of colors for each type. That would be best)
			monster.set_type(i % params[&"colors"])
			bag.append(monster)
	for rowIndex in range(params[&"buffer"]):
		for colIndex in range(params[&"width"]):
			result.append(null)
	var airIndex: int = -1
	for rowIndex in range(params[&"height"]):
		var airColIndex = -1
		if rowIndex + params[&"airHeight"] == params[&"height"]:
			airColIndex = randi_range(0, params[&"width"] - 1)
		for colIndex in range(params[&"width"]):
			if colIndex == airColIndex:
				result.append(Air.instantiate())
				airIndex = result.size() - 1
			else:
				var bagIndex: int = randi_range(0, bag.size() - 1)
				result.append(bag[bagIndex])
				bag.remove_at(bagIndex)
			result[result.size() - 1].gridIndex = result.size() - 1
	#place air and garbage
	if airIndex != -1:
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
