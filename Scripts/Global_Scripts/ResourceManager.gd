extends Node

enum Resource {
	WOOD,
	STONE,
	GOLD,
	FOOD,
	POPULATION,
	EGG
}

var resourceJson
var resourceJsonPath = "res://GameData/resources.json"
func _ready():
	load_resources()
	
func load_resources():
	var file = File.new()
	file.open(resourceJsonPath, file.READ)
	resourceJson.parse_json(file.get_as_text())
	file.close()

func save_resources():
	var settingsFile = File.new()
	settingsFile.open(resourceJsonPath, settingsFile.WRITE)
	settingsFile.store_line(to_json(resourceJson))
	settingsFile.close()

func update_resource(resource, value):
	if resource != null:
		match resource:
			ResourceManager.Resource.WOOD:
				emit_signal("update_resource", Resource.WOOD, value)
				resourceJson["wood"] += value
			ResourceManager.Resource.STONE:
				emit_signal("update_resource", Resource.STONE, value)
				resourceJson["stone"] += value
			ResourceManager.Resource.GOLD:
				emit_signal("update_resource", Resource.GOLD, value)
				resourceJson["gold"] += value
			ResourceManager.Resource.FOOD:
				emit_signal("update_resource", Resource.FOOD, value)
				resourceJson["food"] += value
			ResourceManager.Resource.POPULATION:
				emit_signal("update_resource", Resource.POPULATION, value)
				resourceJson["population"] += value
			ResourceManager.Resource.EGG:
				emit_signal("update_resource", Resource.EGG, value)
				resourceJson["eggs"] += value

