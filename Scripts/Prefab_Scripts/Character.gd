extends "res://Scripts/Prefab_Scripts/MapEntity.gd"

signal movement_done()

var path: PoolVector2Array
var isMoving: bool = false
export var speed := 125
export var health := 20

func _ready():
	._ready()
	set_process(false)
	randomize()
	$MapEntity_Sprite/head/teeth.frame = randi() % 4
	var r_seed = (randf()) + 0.5
	
	var mat_override = get_node("MapEntity_Sprite/arm1").get_material().duplicate()
	$MapEntity_Sprite/arm1.get_material().set_shader_param("seed", r_seed)
	get_node("MapEntity_Sprite/arm1").set_material(mat_override)
	
	mat_override = get_node("MapEntity_Sprite/arm1/hand_l").get_material().duplicate()
	$MapEntity_Sprite/arm1/hand_l.get_material().set_shader_param("seed", r_seed)
	get_node("MapEntity_Sprite/arm1/hand_l").set_material(mat_override)
	
	mat_override = get_node("MapEntity_Sprite/arm2").get_material().duplicate()
	$MapEntity_Sprite/arm2.get_material().set_shader_param("seed", r_seed)
	get_node("MapEntity_Sprite/arm2").set_material(mat_override)
	
	mat_override = get_node("MapEntity_Sprite/arm2/hand_r").get_material().duplicate()
	$MapEntity_Sprite/arm2/hand_r.get_material().set_shader_param("seed", r_seed)
	get_node("MapEntity_Sprite/arm2/hand_r").set_material(mat_override)
	
	mat_override = get_node("MapEntity_Sprite/body").get_material().duplicate()
	$MapEntity_Sprite/body.get_material().set_shader_param("seed", r_seed)
	get_node("MapEntity_Sprite/body").set_material(mat_override)
	
	mat_override = get_node("MapEntity_Sprite/head").get_material().duplicate()
	$MapEntity_Sprite/head.get_material().set_shader_param("seed", r_seed)
	get_node("MapEntity_Sprite/head").set_material(mat_override)
	
	mat_override = get_node("MapEntity_Sprite/head/blush").get_material().duplicate()
	$MapEntity_Sprite/head/blush.get_material().set_shader_param("seed", r_seed)
	get_node("MapEntity_Sprite/head/blush").set_material(mat_override)
	
	mat_override = get_node("MapEntity_Sprite/head/eyes").get_material().duplicate()
	$MapEntity_Sprite/head/eyes.get_material().set_shader_param("seed", r_seed)
	get_node("MapEntity_Sprite/head/eyes").set_material(mat_override)

	mat_override = get_node("MapEntity_Sprite/head/teeth").get_material().duplicate()
	$MapEntity_Sprite/head/teeth.get_material().set_shader_param("seed", r_seed)
	get_node("MapEntity_Sprite/head/teeth").set_material(mat_override)
	print(r_seed)

func move(newPath: PoolVector2Array):
	path = newPath
	isMoving = true
	$AnimationPlayer.play("waddle")
	set_process(true)

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

func _unhandled_input(event):
	if mouseOver and event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			get_tree().set_input_as_handled()
			emit_signal("selected", self)
			$highlight/AnimationPlayer.play("unhighlight")

func remove_highlight():
	$highlight/AnimationPlayer.play("highlight")