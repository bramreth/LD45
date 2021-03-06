extends "res://Scripts/Prefab_Scripts/MapEntity.gd"

export(ResourceManager.Resource) var resourceType := ResourceManager.Resource.WOOD
export(int) var amount := 1
var pickedUp = false

func _ready():
	._ready()
	set_process(false)
	setup(resourceType)
	type = GameManager.ENTITY_TYPE.ITEM

func setup(resource):
	resourceType = resource
	$MapEntity_Sprite.texture = AssetLoader.assets["items"][resourceType]

func pickup():
	if !pickedUp:
		for goblin in get_tree().get_nodes_in_group("goblin"):
			goblin.is_this_current_target(self)
		$Particles2D.emitting = true
		pickedUp = true
		set_process(true)
		ResourceManager.update_resource(resourceType, amount)

func _process(delta):
	if !$Particles2D.emitting and pickedUp:
		queue_free()

func _unhandled_input(event):
	if mouseOver and event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed:
			get_tree().set_input_as_handled()
			emit_signal("selected", self)