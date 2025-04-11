extends Node2D
class_name Lightning

var life: float = 0.2
var startFrameLife: float = 3.0 / 60.0
var frameLife: float = startFrameLife

func _ready() -> void:
	z_index = 3
	$Sprite2D.position.x = 32
	$Sprite2D2.position.x = 90
	$Sprite2D11.position.x = 148
	$Sprite2D12.position.x = 206
	$Sprite2D3.position.x = -32
	$Sprite2D3.rotation = PI
	$Sprite2D4.position.x = -90
	$Sprite2D4.rotation = PI
	$Sprite2D13.position.x = -148
	$Sprite2D13.rotation = PI
	$Sprite2D14.position.x = -206
	$Sprite2D14.rotation = PI
	$Sprite2D5.position.y = 32
	$Sprite2D5.rotation = PI / 2
	$Sprite2D6.position.y = 90
	$Sprite2D6.rotation = PI / 2
	$Sprite2D7.position.y = 148
	$Sprite2D7.rotation = PI / 2
	$Sprite2D15.position.y = 206
	$Sprite2D15.rotation = PI / 2
	$Sprite2D16.position.y = 264
	$Sprite2D16.rotation = PI / 2
	$Sprite2D17.position.y = 322
	$Sprite2D17.rotation = PI / 2
	$Sprite2D8.position.y = -32
	$Sprite2D8.rotation = 3 * PI / 2
	$Sprite2D9.position.y = -90
	$Sprite2D9.rotation = 3 * PI / 2
	$Sprite2D10.position.y = -148
	$Sprite2D10.rotation = 3 * PI / 2
	$Sprite2D18.position.y = -206
	$Sprite2D18.rotation = PI / 2
	$Sprite2D19.position.y = -264
	$Sprite2D19.rotation = PI / 2
	$Sprite2D20.position.y = -322
	$Sprite2D20.rotation = PI / 2
	for child in get_children():
		child.frame = randi_range(0,3)

func set_length(left: int, right: int, up: int, down: int):
	if left <= 2:
		$Sprite2D4.visible = false
	if left <= 4:
		$Sprite2D13.visible = false
	if left <= 5:
		$Sprite2D14.visible = false
	if right <= 2:
		$Sprite2D2.visible = false
	if right <= 4:
		$Sprite2D11.visible = false
	if right <= 5:
		$Sprite2D12.visible = false
	if up <= 2:
		$Sprite2D9.visible = false
	if up <= 4:
		$Sprite2D10.visible = false
	if up <= 6:
		$Sprite2D18.visible = false
	if up <= 8:
		$Sprite2D19.visible = false
	if up <= 9:
		$Sprite2D20.visible = false
	if down <= 2:
		$Sprite2D6.visible = false
	if down <= 4:
		$Sprite2D7.visible = false
	if down <= 6:
		$Sprite2D15.visible = false
	if down <= 8:
		$Sprite2D16.visible = false
	if down <= 9:
		$Sprite2D17.visible = false

func end():
	get_parent().remove_child(self)
	queue_free()

func _physics_process(delta: float) -> void:
	life = life - delta
	if life <= 0.0:
		end()
	else:
		frameLife = frameLife - delta
		if frameLife <= 0.0:
			frameLife = frameLife + startFrameLife
			for child in get_children():
				if child.frame == 3:
					child.frame = 0
				else:
					child.frame = child.frame + 1
