extends Node

var strings = {}
var stringsJson = JSON
var stringsPath = "res://GameData/strings.json"
func _ready():
	load_strings()	
	
func load_strings():
	var file = File.new()
	file.open(stringsPath, file.READ)
	stringsJson = JSON.parse(file.get_as_text())
	print("get strings")
	if stringsJson.error == OK:
		strings = stringsJson.result
		print("got strings")
	file.close()

func get_strings_for_scene(scene_name):
	return strings[scene_name]