extends Node

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
				SystemManager.playerData["resource"]["wood"] += value
			ResourceManager.Resource.STONE:
				emit_signal("update_resource", Resource.STONE, value)
				SystemManager.playerData["resource"]["stone"] += value
			ResourceManager.Resource.GOLD:
				emit_signal("update_resource", Resource.GOLD, value)
				SystemManager.playerData["resource"]["gold"] += value
			ResourceManager.Resource.FOOD:
				emit_signal("update_resource", Resource.FOOD, value)
				SystemManager.playerData["resource"]["food"] += value
			ResourceManager.Resource.POPULATION:
				emit_signal("update_resource", Resource.POPULATION, value)
				SystemManager.playerData["resource"]["population"] += value
			ResourceManager.Resource.EGG:
				emit_signal("update_resource", Resource.EGG, value)
				SystemManager.playerData["resource"]["eggs"] += value

