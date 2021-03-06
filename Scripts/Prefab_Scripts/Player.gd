extends "res://Scripts/Prefab_Scripts/Character.gd"

signal movement_done()

func _ready():
	._ready()
	type = GameManager.ENTITY_TYPE.PLAYER

func _process(delta):
	if !path:
		isMoving = false
		$AnimationPlayer.stop()
		$Tween.interpolate_property($MapEntity_Sprite, "offset", $MapEntity_Sprite.offset, 0, 0.1, Tween.TRANS_CUBIC, Tween.EASE_IN)
		$Tween.interpolate_property($MapEntity_Sprite, "rotation_degrees", $MapEntity_Sprite.rotation_degrees, 0, 0.1, Tween.TRANS_CUBIC, Tween.EASE_IN)
		$Tween.start()
		emit_signal("movement_done", self)
		set_process(false)
	if path.size() > 0:
		var d: float = position.distance_to(path[0])
		if d > 10:
			position = position.linear_interpolate(path[0], (speed * delta)/d)
		else:
			path.remove(0)
			
func get_details():
	return[str(100), str(100), str(100), str(100), str(20), SystemManager.data["player_data"]["name"], "just being you"]