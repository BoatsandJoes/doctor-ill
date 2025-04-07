extends Piece
class_name Omni

var monsterSkins: Array[Dictionary] = [
{&"name": "snake", &"hFrames": 4, &"vFrames": 1},
{&"name": "frog", &"hFrames": 3, &"vFrames": 1},
{&"name": "dino", &"hFrames": 4, &"vFrames": 1},
{&"name": "cactus", &"hFrames": 2, &"vFrames": 1},
{&"name": "slime", &"hFrames": 3, &"vFrames": 1},
{&"name": "skeleton", &"hFrames": 4, &"vFrames": 1}]

func _ready() -> void:
	matchVecs = [Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(-1, 0)]
	variety = 1

func set_type(type: int):
	$Sprite2D.texture = load("res://assets/sprites/" + monsterSkins[type][&"name"] + ".png")
	$Sprite2D.hframes = monsterSkins[type][&"hFrames"]
	$Sprite2D.vframes = monsterSkins[type][&"vFrames"]
	self.type = type

func animate():
	if monsterSkins[type][&"hFrames"] == 4:
		$AnimationPlayer.play("snake")
	elif monsterSkins[type][&"hFrames"] == 2:
		$AnimationPlayer.play("cactus")
	elif monsterSkins[type][&"hFrames"] == 3:
		$AnimationPlayer.play("frog")
	$AnimationPlayer.queue("RESET")
