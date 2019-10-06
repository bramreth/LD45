extends Node

onready var strings = SystemManager.data["dialog"]

func get_dialog(scene_name):
	return strings[scene_name]