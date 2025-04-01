extends Piece
class_name Diag

var monsterSkins: Array[Dictionary] = [
{&"name": "fairy", &"hFrames": 4, &"vFrames": 1},
{&"name": "bat", &"hFrames": 2, &"vFrames": 1},
{&"name": "whirlwind", &"hFrames": 4, &"vFrames": 1},
{&"name": "ghost", &"hFrames": 3, &"vFrames": 1},
{&"name": "imp", &"hFrames": 3, &"vFrames": 1},
{&"name": "eye", &"hFrames": 3, &"vFrames": 1}]

func _ready() -> void:
	matchVecs = [Vector2i(-1, -1), Vector2i(1, -1)]
	variety = 2

func set_type(type: int):
	$Sprite2D.texture = load("res://assets/sprites/" + monsterSkins[type][&"name"] + ".png")
	$Sprite2D.hframes = monsterSkins[type][&"hFrames"]
	$Sprite2D.vframes = monsterSkins[type][&"vFrames"]
	self.type = type
