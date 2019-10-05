extends Node2D

signal selected()

var mouseOver = false

func _ready():
	$Click_Area.connect("mouse_entered",self,"mouse_over", [true])
	$Click_Area.connect("mouse_exited",self,"mouse_over", [false])

func get_position():
	return position + $Entrance.position

func mouse_over(m):
	mouseOver = m

func _unhandled_input(event):
	if mouseOver and event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed:
			get_tree().set_input_as_handled()
			emit_signal("selected", self)