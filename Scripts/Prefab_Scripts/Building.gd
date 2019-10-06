extends "res://Scripts/Prefab_Scripts/MapEntity.gd"

enum Building {
	CAMP,
	HUT,
	SENTRY,
	HATCHERY,
	MESS
}

var building_type

func setup(resource):
	building_type = resource
	print("BRAM MARKER")
	print(resource)
#	$MapEntity_Sprite.texture = AssetLoader.assets["resources"][resourceType]
	match building_type:
		"hut":
			ResourceManager.update_resource(ResourceManager.Resource.MAX_POPULATION, 5)
			print("hut built!!", ResourceManager.get_value(ResourceManager.Resource.MAX_POPULATION))
	
func _ready():
	._ready()
	type = GameManager.ENTITY_TYPE.BUILDING

func get_position():
	return position + $Entrance.position

func _unhandled_input(event):
	if mouseOver and event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed:
			get_tree().set_input_as_handled()
			emit_signal("selected", self)