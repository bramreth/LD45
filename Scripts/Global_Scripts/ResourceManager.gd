extends Node

signal update_resource(res, val)


enum Resource {
	WOOD,
	STONE,
	GOLD,
	FOOD,
	POPULATION,
	EGG
}

func _ready():
	pass
	
func update_resource(resource, value):
	if resource != null:
		match resource:
			ResourceManager.Resource.WOOD:
				emit_signal("update_resource", Resource.WOOD, value)
				SystemManager.playerData["resources"]["wood"] += value
			ResourceManager.Resource.STONE:
				emit_signal("update_resource", Resource.STONE, value)
				SystemManager.playerData["resources"]["stone"] += value
			ResourceManager.Resource.GOLD:
				emit_signal("update_resource", Resource.GOLD, value)
				SystemManager.playerData["resources"]["gold"] += value
			ResourceManager.Resource.FOOD:
				emit_signal("update_resource", Resource.FOOD, value)
				SystemManager.playerData["resources"]["food"] += value
			ResourceManager.Resource.POPULATION:
				emit_signal("update_resource", Resource.POPULATION, value)
				SystemManager.playerData["resources"]["population"] += value
			ResourceManager.Resource.EGG:
				emit_signal("update_resource", Resource.EGG, value)
				SystemManager.playerData["resources"]["eggs"] += value

