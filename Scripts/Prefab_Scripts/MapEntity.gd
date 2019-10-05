extends Node2D

signal selected()

var type

var mouseOver = false

func _ready():
	$Click_Area.connect("mouse_entered",self,"mouse_over", [true])
	$Click_Area.connect("mouse_exited",self,"mouse_over", [false])

func mouse_over(m):
	mouseOver = m