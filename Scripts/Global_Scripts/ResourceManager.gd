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
				SystemManager.data["player_data"]["resources"]["wood"] += value
				emit_signal("update_resource", Resource.WOOD)
			ResourceManager.Resource.STONE:
				SystemManager.data["player_data"]["resources"]["stone"] += value
				emit_signal("update_resource", Resource.STONE)
			ResourceManager.Resource.GOLD:
				SystemManager.data["player_data"]["resources"]["gold"] += value
				emit_signal("update_resource", Resource.GOLD)
			ResourceManager.Resource.FOOD:
				SystemManager.data["player_data"]["resources"]["food"] += value
				emit_signal("update_resource", Resource.FOOD)
			ResourceManager.Resource.POPULATION:
				if typeof(value) == TYPE_ARRAY && value.size() == 2: 
					SystemManager.data["player_data"]["resources"]["population"] = value
				emit_signal("update_resource", Resource.POPULATION)
			ResourceManager.Resource.EGG:
				SystemManager.data["player_data"]["resources"]["eggs"] += value
				emit_signal("update_resource", Resource.EGG)

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
