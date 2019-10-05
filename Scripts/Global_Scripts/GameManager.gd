extends Node

signal start_dialog(scene)

enum ENTITY_TYPE {
	CHARACTER,
	BUILDING,
	ITEM
}

func start_dialog(scene):
	if scene != null && !scene.empty():
		emit_signal("start_dialog", scene)