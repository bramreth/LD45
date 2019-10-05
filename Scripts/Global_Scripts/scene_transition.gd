extends Node

var scene_list = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	scene_list["menu"] = "main_menu"
	scene_list["tutorial"] = "tutorial"
	scene_list["game"] = "Game"

func change_scene(scene):
	get_tree().change_scene("res://Scenes/" + scene_list[scene] + ".tscn")
