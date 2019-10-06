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
				SystemManager.data["player_data"]["resources"]["wood"] += value
			ResourceManager.Resource.STONE:
				emit_signal("update_resource", Resource.STONE, value)
				SystemManager.data["player_data"]["resources"]["stone"] += value
			ResourceManager.Resource.GOLD:
				emit_signal("update_resource", Resource.GOLD, value)
				SystemManager.data["player_data"]["resources"]["gold"] += value
			ResourceManager.Resource.FOOD:
				emit_signal("update_resource", Resource.FOOD, value)
				SystemManager.data["player_data"]["resources"]["food"] += value
			ResourceManager.Resource.POPULATION:
				emit_signal("update_resource", Resource.POPULATION, value)
				SystemManager.data["player_data"]["resources"]["population"] += value
			ResourceManager.Resource.EGG:
				emit_signal("update_resource", Resource.EGG, value)
				SystemManager.data["player_data"]["resources"]["eggs"] += value

func get_value(resource):
	match resource:
			ResourceManager.Resource.WOOD:
				return SystemManager.data["player_data"]["resources"]["wood"] 
			ResourceManager.Resource.STONE:
				return SystemManager.data["player_data"]["resources"]["stone"] 
			ResourceManager.Resource.GOLD:
				return SystemManager.data["player_data"]["resources"]["gold"] 
			ResourceManager.Resource.FOOD:
				return SystemManager.data["player_data"]["resources"]["food"] 
			ResourceManager.Resource.POPULATION:
				return SystemManager.data["player_data"]["resources"]["population"] 
			ResourceManager.Resource.EGG:
				return SystemManager.data["player_data"]["resources"]["eggs"] 
