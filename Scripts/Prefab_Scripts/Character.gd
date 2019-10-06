extends "res://Scripts/Prefab_Scripts/MapEntity.gd"

signal movement_done()

var path: PoolVector2Array
var isMoving: bool = false
export(bool) var isPlayer := false
export var speed := 125

# goblin stats
export var health = 20
export var hunger = 100
export var energy = 100
export var happiness = 100
export var strength = 5

# possible jobs
var jobs = ["gather", "rest", "relax", "eat", "build", "fight", "wander"]

func determine_jobs():
	# essentials
	if combat_in_proximity():
		return "fight"
	if build_in_proximity():
		return "fight"
	if hunger < 40:
		return "eat"
	if energy < 30:
		return "rest"
		
	randomize()
	var free_will = randi() % 100
	if free_will <= 30:
		return "gather"
	elif free_will <= 60:
		return "relax"
	elif free_will <= 80:
		return "wander"
	elif free_will <= 90:
		return "eat"
	else:
		return "rest"
	
	
func combat_in_proximity():
	return false
	
func build_in_proximity():
	return false
	
func handle_job():
	var job = determine_jobs()
	match job:
		"gather":
			gather()
		"rest":
			rest()
		"relax":
			relax()
		"eat":
			eat()
		"build":
			build()
		"fight":
			fight()
		"wander":
			wander()
	print(job)
	drain_energy_and_food()
	log_stats()
	yield(get_tree().create_timer(randi()%20 + 4), "timeout")
	handle_job()

func log_stats():
	print("hunger", hunger) 
	print("energy", energy) 
	print("happiness", happiness) 
	print("hunger", hunger) 
			
func gather():
	happiness -=10
	if(happiness < 0):
		happiness = 0
	hunger -=10
	if(hunger < 0):
		hunger = 0
	energy -=10
	if(energy < 0):
		energy = 0
	
func rest():
	energy +=50
	if(energy > 100):
		energy = 100
	happiness +=10
	if(happiness > 100):
		happiness = 100
	
func relax():
	energy +=10
	if(energy > 100):
		energy = 100
	happiness +=50
	if(happiness > 100):
		happiness = 100
	
func eat():
	hunger +=50
	if(hunger > 100):
		hunger = 100
	happiness +=10
	if(happiness > 100):
		happiness = 100

func build():
	happiness -=10
	if(happiness < 0):
		happiness = 0
	hunger -=10
	if(hunger < 0):
		hunger = 0
	energy -=10
	if(energy < 0):
		energy = 0
	
func fight():
	happiness -=10
	if(happiness < 0):
		happiness = 0
	hunger -=10
	if(hunger < 0):
		hunger = 0
	energy -=10
	if(energy < 0):
		energy = 0
	
func wander():
	energy -=10
	if(energy < 0):
		energy = 0
	happiness +=10
	if(happiness > 100):
		happiness = 100
	
func drain_energy_and_food():
	hunger -= 2
	energy -= 3
	

func _ready():
	._ready()
	if !isPlayer:
		type = GameManager.ENTITY_TYPE.CHARACTER
	else :
		type = GameManager.ENTITY_TYPE.PLAYER
	set_process(false)
	handle_job()
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