extends "res://Scripts/Prefab_Scripts/Character.gd"

signal request_job_target()

# goblin stats
export var gname = "goblin"
export var hunger = 100
export var energy = 100
export var happiness = 100
export var strength = 5

# possible jobs
var jobs = ["gather", "rest", "relax", "eat", "build", "fight", "wander"]
#Gather - go to neareast item on the floor and pick up
#Rest - go to neareast hut and sleep
#Relax - go to the nearest campfire and relax
#Eat - go to the nearest mess hall and attempt to eat 1-3 food
#Build - go to the neareast construction site and help
#Fight - for to the neareast combat node and join the fight
#Wander - wander around the town

var currentJob = "idle"
var currentTarget = null

func _ready():
	._ready()
	print("READY GOBLIN ++++++++++++++++++++++++++++")
	randomize()
	type = GameManager.ENTITY_TYPE.GOBLIN
	yield(get_tree().create_timer(randi()%3+1), "timeout")
	start_job()

func join_clan():
	emit_signal("request_job_target", self, "join")

func determine_jobs():
	return "wander"
	# essentials
	if combat_in_proximity():
		return "fight"
	if build_in_proximity():
		return "fight"
	if hunger < 40:
		return "eat"
	if energy < 30:
		return "rest"
		

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
	
func start_job():
	currentJob = determine_jobs()
	emit_signal("request_job_target", self, currentJob)

#Gets a path to the job target and the target from the Game script
func handle_job(path, target):
	currentTarget = target
	
	if path != null:
		move(path)
	else:
		job_movement_done()

func job_movement_done():
	drain_energy_and_food()
	call(currentJob)

func finish_job():
	currentJob = "idle"
	currentTarget = null
	yield(get_tree().create_timer(randi()%5+1), "timeout")
	start_job()

func log_stats():
	print("hunger", hunger) 
	print("energy", energy) 
	print("happiness", happiness) 

func adjust_stats(hun, ener, happ):
	hunger += hun
	energy += ener
	happiness += happ
	
	if hunger < 0:
		hunger = 0
	elif hunger > 100:
		hunger = 100
	
	if energy < 0:
		energy = 0
	elif energy > 100:
		energy = 100
	
	if happiness < 0:
		happiness = 0
	elif happiness > 100:
		happiness = 100

func gather():
	adjust_stats(-10,-10,-10)

func rest():
	if currentTarget != null:
		adjust_stats(0,50,10)
		var success = currentTarget.use_building(self)
		if !success: #House is full :(
			emit_signal("request_job_target", self, currentJob)
	else :
		finish_job()

func relax():
	adjust_stats(0,50,10)
	
func eat():
	adjust_stats(50,0,10)

func build():
	adjust_stats(-10,-10,-10)
	
func fight():
	adjust_stats(-10,-10,-10)

func wander():
	adjust_stats(0,-10,10)
	finish_job()

func drain_energy_and_food():
	adjust_stats(-2,-3,0)

func _process(delta):
	if !path:
		isMoving = false
		$AnimationPlayer.stop()
		$Tween.interpolate_property($MapEntity_Sprite, "offset", $MapEntity_Sprite.offset, 0, 0.1, Tween.TRANS_CUBIC, Tween.EASE_IN)
		$Tween.interpolate_property($MapEntity_Sprite, "rotation_degrees", $MapEntity_Sprite.rotation_degrees, 0, 0.1, Tween.TRANS_CUBIC, Tween.EASE_IN)
		$Tween.start()
		job_movement_done()
		set_process(false)
	if path.size() > 0:
		var d: float = position.distance_to(path[0])
		if d > 10:
			position = position.linear_interpolate(path[0], (speed * delta)/d)
		else:
			path.remove(0)
			
func get_details():
	return[str(health), str(hunger), str(energy), str(happiness), str(strength), str(gname), currentJob]