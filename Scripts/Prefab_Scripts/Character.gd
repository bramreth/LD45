extends Node2D

signal selected()

var path: PoolVector2Array
var isMoving: bool = false
var mouseOver = false
export var speed := 250

func _ready():
	$Click_Area.connect("mouse_entered",self,"mouse_over", [true])
	$Click_Area.connect("mouse_exited",self,"mouse_over", [false])
	set_process(false)

func mouse_over(m):
	mouseOver = m

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
