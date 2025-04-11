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

func animate():
	if monsterSkins[type][&"hFrames"] == 4:
		$AnimationPlayer.play("fairy")
	elif monsterSkins[type][&"hFrames"] == 2:
		$AnimationPlayer.play("bat")
	elif monsterSkins[type][&"hFrames"] == 3:
		$AnimationPlayer.play("ghost")
	$AnimationPlayer.queue("RESET")

func _physics_process(delta: float) -> void:
	if $Lightning.visible:
		lightingFrameTime = lightingFrameTime - delta
		if lightingFrameTime <= 0:
			lightingFrameTime = lightingFrameTime + lightningFrameHold
			if $Lightning.frame >= 6:
				$Lightning.frame = 0
			else: $Lightning.frame = $Lightning.frame + 1
	if $Fire.visible:
		fireFrameTime = fireFrameTime - delta
		if fireFrameTime <= 0:
			fireFrameTime = fireFrameTime + fireFrameHold
			if $Fire.frame >= 6:
				$Fire.frame = 0
			else: $Fire.frame = $Fire.frame + 1
