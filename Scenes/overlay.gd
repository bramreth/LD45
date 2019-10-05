extends Control

func _ready():
	ResourceManager.connect("update_resource", self, "update_resource")
	$options_menu.hide()
	pass 


func update_resource(resource, value):
	if resource != null:
		var value_to_update
		match resource:
			ResourceManager.Resource.WOOD:
				value_to_update = $bottom_menu/bottom_menu_list/resources/wood/value
			ResourceManager.Resource.STONE:
				value_to_update = $bottom_menu/bottom_menu_list/resources/stone/value
			ResourceManager.Resource.GOLD:
				value_to_update = $bottom_menu/bottom_menu_list/resources/gold/value
			ResourceManager.Resource.FOOD:
				value_to_update = $bottom_menu/bottom_menu_list/resources/food/value
			ResourceManager.Resource.POPULATION:
				value_to_update = $bottom_menu/bottom_menu_list/resources/population/value
			ResourceManager.Resource.EGG:
				value_to_update = $bottom_menu/bottom_menu_list/resources/eggs/value
		if value_to_update != null:
			print("do the update bit!")
			value_to_update.text = String(int(value_to_update.text) + value)
			#TODO ANIMATION!

func _on_settings_button_pressed():
	if $options_menu.is_visible_in_tree():
		$options_menu.hide()
	else:
		$options_menu.show()


func _on_resume_button_pressed():
	$options_menu.hide()


func _on_quit_button_pressed():
	scene_transition.change_scene("menu")
