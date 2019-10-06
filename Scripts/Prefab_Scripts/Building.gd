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
	print(resource)
#	$MapEntity_Sprite.texture = AssetLoader.assets["resources"][resourceType]
	
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