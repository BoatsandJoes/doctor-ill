extends Piece
class_name Omni

var monsterSkins: Array[Dictionary] = [{&"name": "frog", &"frames": 3},
{&"name": "dino", &"frames": 4},
{&"name": "skeleton", &"frames": 4},
{&"name": "slime", &"frames": 3}]

func _ready() -> void:
	matchVecs = [Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(-1, 0)]
	variety = 1

func set_type(type: int):
	$Sprite2D.texture = load("res://assets/sprites/" + monsterSkins[type][&"name"] + ".png")
	$Sprite2D.hframes = monsterSkins[type][&"frames"]
	self.type = type
