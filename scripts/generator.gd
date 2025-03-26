extends Object
class_name Generator

func generateLevel(params: Dictionary) -> Array:
	var result: Array = []
	var bag: Array = []
	var monCount: int = params[&"height"] * params[&"width"]
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
	for rowIndex in range(params[&"height"]):
		for colIndex in range(params[&"width"]):
			var bagIndex: int = randi_range(0, bag.size() - 1)
			result.append(bag[bagIndex])
			bag.remove_at(bagIndex)
			result[result.size() - 1].gridIndex = result.size() - 1
	return result
