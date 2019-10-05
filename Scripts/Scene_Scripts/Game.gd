extends Node2D

onready var navigation: Navigation2D = $Map/Navigation
onready var player = $Map/Navigation/Character

var path : PoolVector2Array
var goal : Vector2

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			goal = event.position
			path = navigation.get_simple_path(player.position, goal, false)
			print(goal)
			print(player.position)
			print(path)
			player.move(path)