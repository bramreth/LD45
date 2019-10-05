extends "res://Scripts/Prefab_Scripts/MapEntity.gd"

var path: PoolVector2Array
var isMoving: bool = false
export var speed := 250

func _ready():
	._ready()
	set_process(false)

func move(newPath: PoolVector2Array):
	path = newPath
	isMoving = true
	set_process(true)

func _process(delta):
	if !path:
		isMoving = false
		set_process(false)
	if path.size() > 0:
		var d: float = position.distance_to(path[0])
		if d > 10:
			position = position.linear_interpolate(path[0], (speed * delta)/d)
		else:
			path.remove(0)

func _unhandled_input(event):
	if mouseOver and event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			get_tree().set_input_as_handled()
			emit_signal("selected", self)
