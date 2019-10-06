extends "res://Scripts/Prefab_Scripts/MapEntity.gd"

signal req_path()

var path: PoolVector2Array
var isMoving: bool = false
export var speed := 125

# Called when the node enters the scene tree for the first time.
func _ready():
	type = GameManager.ENTITY_TYPE.GOBLIN
	set_process(false)

func move(newPath: PoolVector2Array):
	path = newPath
	isMoving = true
	set_process(true)
	
func _process(delta):
	if !path:
		isMoving = false
		$Tween.interpolate_property($MapEntity_Sprite, "offset", $MapEntity_Sprite.offset, 0, 0.1, Tween.TRANS_CUBIC, Tween.EASE_IN)
		$Tween.interpolate_property($MapEntity_Sprite, "rotation_degrees", $MapEntity_Sprite.rotation_degrees, 0, 0.1, Tween.TRANS_CUBIC, Tween.EASE_IN)
		$Tween.start()
		set_process(false)
	if path.size() > 0:
		var d: float = position.distance_to(path[0])
		if d > 10:
			position = position.linear_interpolate(path[0], (speed * delta)/d)
		else:
			path.remove(0)

func _on_Timer_timeout():
	add_path()
	$Timer.start()
	
func add_path():
	emit_signal("req_path")
