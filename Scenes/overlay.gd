extends Control

func _ready():
	self.connect("update_resource", self, "update_resource")
	pass 


func update_resource(resource, value):
	if resource != null:
		var value_to_update
		match resource:
			ResourceManager.Resource.WOOD:
				value_to_update = $bottom_menu/resources/wood/value
			ResourceManager.Resource.STONE:
				value_to_update = $bottom_menu/resources/stone/value
			ResourceManager.Resource.GOLD:
				value_to_update = $bottom_menu/resources/gold/value
			ResourceManager.Resource.FOOD:
				value_to_update = $bottom_menu/resources/food/value
			ResourceManager.Resource.POPULATION:
				value_to_update = $bottom_menu/resources/population/value
			ResourceManager.Resource.EGG:
				value_to_update = $bottom_menu/resources/eggs/value
		if value_to_update != null:
			value_to_update.text += value
			#TODO ANIMATION!