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
	randomize()
	type = GameManager.ENTITY_TYPE.GOBLIN
	yield(get_tree().create_timer(randf()*3+1), "timeout")
	start_job()

func join_clan():
	emit_signal("request_job_target", self, "join")
	start_specific_job("wander")

func determine_jobs():
	
	print(check_for_construction())
	
	# essentials
	if check_for_combat():
		return "fight"
	if check_for_construction():
		return "build"
	if hunger < 40:
		return "eat"
	if energy < 30:
		return "rest"
	if happiness < 30:
		return "relax"
	
	var free_will = randi() % 100
	if free_will <= 49:
		if GameManager.is_daytime():
			return "gather"
		else:
			return "rest"
	return "wander"

func check_for_combat():
	false
	
func check_for_construction():
	for site in get_tree().get_nodes_in_group("construction_sites"):
		if !site.is_at_capacity():
			return true
	return false

func start_job():
	currentJob = determine_jobs()
	emit_signal("request_job_target", self, currentJob)

func start_specific_job(job):
	currentJob = job
	emit_signal("request_job_target", self, currentJob)

func handle_job(path, target):
	#wander doesn't need a target
	if currentJob == "wander" and path != null:
		move(path)
		return
	
	#Eat, rest and relax can be done without a target on te spot
	if target == null and (currentJob in ["eat", "rest", "relax"]):
		yield(get_tree().create_timer(10), "timeout")
		match currentJob:
			"eat": 
				adjust_stats(10,0,5)
			"rest":
				adjust_stats(0,10,5)
			"relax":
				adjust_stats(0,5,10)
		finish_job()
		return
	#Other jobs require a target and will just end
	elif target == null:
		finish_job()
		return
	
	currentTarget = target
	move(path)

func job_movement_done():
	drain_energy_and_food()
	call(currentJob)

func finish_job():
	currentJob = "idle"
	currentTarget = null
	yield(get_tree().create_timer(randf()*10+1), "timeout")
	start_job()

func is_this_current_target(target):
	if currentTarget == target:
		cancel_job()

func cancel_job():
	set_process(false)
	currentJob = "idle"
	currentTarget = null
	adjust_stats(-2,-2,-2)
	yield(get_tree().create_timer(randf()*3+1), "timeout")
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
	currentTarget.pickup()
	adjust_stats(-10,-10,-10)
	finish_job()

func rest():
	currentTarget.use_building(self)
	adjust_stats(0,50,30)

func relax():
	currentTarget.use_building(self)
	adjust_stats(0,30,50)

func eat():
	currentTarget.use_building(self)
	adjust_stats(50,0,30)

func build():
	currentTarget.use_building(self)
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
		set_process(false)
		job_movement_done()
	if path.size() > 0:
		var d: float = position.distance_to(path[0])
		if d > 20:
			position = position.linear_interpolate(path[0], (speed * delta)/d)
		else:
			path.remove(0)

func get_details():
	return[str(health), str(hunger), str(energy), str(happiness), str(strength), str(gname), currentJob]

#
#func gather():
#	print("GATHERING")
#	if GameManager.is_daytime():
#		if !currentTarget.get_ref():
#			adjust_stats(-2,-2,-2)
#			finish_job()
#		else: 
#			currentTarget = currentTarget.get_ref()
#			if currentTarget != null:
#				if !currentTarget.pickedUp:
#					currentTarget.pickup()
#					adjust_stats(-10,-10,-10)
#					finish_job()
#				else:
#					adjust_stats(-2,-2,-2)
#					emit_signal("request_job_target", self, currentJob)
#			else :
#				adjust_stats(-2,-2,-2)
#				finish_job()
#	else:
#		finish_job()
#
#func rest():
#	print("RESTING")
#	if currentTarget != null:
#		var success = currentTarget.use_building(self)
#		if !success: #House is full :(
#			adjust_stats(-2,-2,-2)
#			emit_signal("request_job_target", self, currentJob)
#		else:
#			adjust_stats(0,50,30)
#	else :
#		yield(get_tree().create_timer(10), "timeout")
#		adjust_stats(0,10,5)
#		finish_job()
#
#func relax():
#	print("RELAXING")
#	if currentTarget != null:
#		var success = currentTarget.use_building(self)
#		if !success: #Fire is full
#			adjust_stats(-2,-2,-2)
#			emit_signal("request_job_target", self, currentJob)
#		else:
#			adjust_stats(0,30,50)
#	else :
#		yield(get_tree().create_timer(10), "timeout")
#		adjust_stats(0,5,10)
#		finish_job()
#
#func eat():
#	print("EATING")
#	if currentTarget != null:
#		var success = currentTarget.use_building(self)
#		if !success: #Mess is full
#			adjust_stats(-2,-2,-2)
#			emit_signal("request_job_target", self, currentJob)
#		else:
#			adjust_stats(50,0,30)
#	else :
#		yield(get_tree().create_timer(10), "timeout")
#		adjust_stats(10,0,5)
#		finish_job()
#
#func build():
#	print("BUILDING")
#	if currentTarget != null:
#		var success = currentTarget.use_building(self)
#		if !success: #Construction
#			adjust_stats(-2,-2,-2)
#			finish_job()
#		else:
#			adjust_stats(-10,-10,-10)
#	else :
#		finish_job()

#Gets a path to the job target and the target from the Game script
#func ahandle_job(path, target):
#	if currentJob == "gather" and target != null:
#		currentTarget = weakref(target)
#	else:
#		currentTarget = target
#
#	if currentJob == "gather" and currentTarget == null:
#		finish_job()
#	else:
#		if path != null:
#			move(path)
#		else:
#			job_movement_done()