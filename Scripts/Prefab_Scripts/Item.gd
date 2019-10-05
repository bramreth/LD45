extends "res://Scripts/Prefab_Scripts/MapEntity.gd"

export(ResourceManager.Resource) var resourceType := ResourceManager.Resource.WOOD
export(int) var amount := 1

func _ready():
	._ready()
	type = GameManager.ENTITY_TYPE.ITEM
	$MapEntity_Sprite.texture = AssetLoader.assets["resources"][resourceType]

func pickup():
	ResourceManager.update_resource(resourceType, amount)
	queue_free()

func _unhandled_input(event):
	if mouseOver and event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed:
			get_tree().set_input_as_handled()
			emit_signal("selected", self)