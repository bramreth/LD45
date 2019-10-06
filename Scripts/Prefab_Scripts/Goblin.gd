extends "res://Scripts/Prefab_Scripts/Character.gd"

signal request_job_target()

# goblin stats
export var hunger = 100
export var energy = 100
export var happiness = 100
export var strength = 5

# possible jobs
var jobs = ["gather", "rest", "relax", "eat", "build", "fight", "wander"]

func _ready():
	._ready()
	randomize()
	type = GameManager.ENTITY_TYPE.CHARACTER
	start_job()

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
	var job = determine_jobs()
	print(job + " IS MY NEW JOB")
	emit_signal("request_job_target", job)

func handle_job(job, path, target):
	call(job, path, target)
	drain_energy_and_food()
	log_stats()

func finish_job():
	yield(get_tree().create_timer(randi()%20 + 4), "timeout")
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

func gather(path, target):
	adjust_stats(-10,-10,-10)

func rest(path, target):
	adjust_stats(0,50,10)

func relax(path, target):
	adjust_stats(0,50,10)
	
func eat(path, target):
	adjust_stats(50,0,10)

func build(path, target):
	adjust_stats(-10,-10,-10)
	
func fight(path, target):
	adjust_stats(-10,-10,-10)

func wander(path, target):
	print("WANDERING")
	adjust_stats(0,-10,10)
	move(path)
	
func drain_energy_and_food():
	adjust_stats(-2,-3,0)