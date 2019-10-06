extends "res://Scripts/Prefab_Scripts/Character.gd"

# goblin stats
export var hunger = 100
export var energy = 100
export var happiness = 100
export var strength = 5

# possible jobs
var jobs = ["gather", "rest", "relax", "eat", "build", "fight", "wander"]

func _ready():
	._ready()
	type = GameManager.ENTITY_TYPE.CHARACTER
	handle_job()

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
	