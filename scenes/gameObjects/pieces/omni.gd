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

func win(_animation: String):
	if monsterSkins[type][&"hFrames"] == 4:
		$AnimationPlayer.play("snake")
	elif monsterSkins[type][&"hFrames"] == 2:
		$AnimationPlayer.play("cactus")
	elif monsterSkins[type][&"hFrames"] == 3:
		$AnimationPlayer.play("frog")
	$AnimationPlayer.animation_finished.connect(win2)

func win2(_animation: String):
	if monsterSkins[type][&"hFrames"] == 4:
		$AnimationPlayer.play("snake")
	elif monsterSkins[type][&"hFrames"] == 2:
		$AnimationPlayer.play("cactus")
	elif monsterSkins[type][&"hFrames"] == 3:
		$AnimationPlayer.play("frog")

func animate():
	if !$AnimationPlayer.current_animation == "clear":
		if monsterSkins[type][&"hFrames"] == 4:
			$AnimationPlayer.play("snake")
		elif monsterSkins[type][&"hFrames"] == 2:
			$AnimationPlayer.play("cactus")
		elif monsterSkins[type][&"hFrames"] == 3:
			$AnimationPlayer.play("frog")
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
