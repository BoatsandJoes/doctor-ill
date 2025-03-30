extends Piece
class_name Diag

var monsterSkins: Array[Dictionary] = [{&"name": "ghost", &"frames": 3},
{&"name": "bat", &"frames": 3},
{&"name": "eye", &"frames": 3}]

func _ready() -> void:
	matchVecs = [Vector2i(-1, -1), Vector2i(1, -1)]
	variety = 2

func set_type(type: int):
	$Sprite2D.texture = load("res://assets/sprites/" + monsterSkins[type][&"name"] + ".png")
	$Sprite2D.hframes = monsterSkins[type][&"frames"]
	self.type = type
