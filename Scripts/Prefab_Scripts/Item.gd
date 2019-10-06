extends "res://Scripts/Prefab_Scripts/MapEntity.gd"

export(ResourceManager.Resource) var resourceType
export(int) var amount := 1
var pickedUp = false

func _ready():
	._ready()
	set_process(false)
	setup(resourceType)
	type = GameManager.ENTITY_TYPE.ITEM

func setup(resource):
	resourceType = resource
	$MapEntity_Sprite.texture = AssetLoader.assets["resources"][resourceType]

func pickup():
	if !pickedUp:
		$Particles2D.emitting = true
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