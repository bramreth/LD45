extends "res://Scripts/Prefab_Scripts/MapEntity.gd"

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