extends Node

signal start_dialog(scene)

signal spawn_items()
signal spawn_goblin()
signal spawn_enemies()

signal day_started()
signal night_started(event)
signal gameplay_tick()

signal update_attractiveness()

var debug_flag = false

onready var night_events = SystemManager.data["events"]["night"]

const DAY_LENGTH = 800
const NIGHT_LENGTH = 400

var currentTick: int = 0 #1/60th seconds since started
var currentGamePlayTick: int = 0 #Seconds since started
var currentDay: int = 0 #number of day/night cycles since started

enum ENTITY_TYPE {
	GOBLIN,
	ENEMY,
	BUILDING,
	ITEM,
	PLAYER,
}

enum Building {
	CAMP,
	HUT,
	SENTRY,
	HATCHERY,
	MESS
}

func start_dialog(scene):
	if scene != null && !scene.empty():
		emit_signal("start_dialog", scene)
		

var spawn_items_list = {
	ResourceManager.Resource.EGG: 0,
	ResourceManager.Resource.FOOD: 0,
	ResourceManager.Resource.GOLD: 0,
	ResourceManager.Resource.STONE: 0,
	ResourceManager.Resource.WOOD: 0
}

func _ready():
	randomize()
	set_physics_process(false)
	update_goblin_spawn_rate()

func start_game():
	set_physics_process(true)

func is_daytime():
	if((currentGamePlayTick)%(DAY_LENGTH+NIGHT_LENGTH) < DAY_LENGTH):
		return true
	return false

func get_current_day():
	return currentTick/(60*(DAY_LENGTH+NIGHT_LENGTH))

func _physics_process(delta):
	currentGamePlayTick = currentTick/60
	debug_day_cycle_print()
	
	if currentTick%60 == 0:
		emit_signal("gameplay_tick")
		if is_daytime():
			check_for_goblin_spawn()
			if(currentGamePlayTick%(DAY_LENGTH+NIGHT_LENGTH) == 0):
				start_of_daytime_tick()
			else:
				daytime_tick()
		else:
			if(currentGamePlayTick%(DAY_LENGTH+NIGHT_LENGTH) == DAY_LENGTH):
				start_of_nighttime_tick()
			else:
				nighttime_tick()
	
	currentTick += 1

func start_of_daytime_tick():
	emit_signal("day_started")
	#print("Day Started " + String(currentGamePlayTick))
	spawn_items_list[ResourceManager.Resource.EGG] = randi()%2
	spawn_items_list[ResourceManager.Resource.FOOD] = randi()%4+1
	spawn_items_list[ResourceManager.Resource.GOLD] = randi()%4
	spawn_items_list[ResourceManager.Resource.STONE] = randi()%6+1
	spawn_items_list[ResourceManager.Resource.WOOD] = randi()%6+1
	emit_signal("spawn_items", spawn_items_list)
	#print(spawn_items_list)

func daytime_tick():
	pass
	#TODO - ADD FUNCTIONALITY TO HAPPEN DURING DAYTIME


var prev_events = []
func start_of_nighttime_tick():
	var event = {}
	var finished_search
	for night_event in night_events:
		if night_event["min-population"] <= ResourceManager.get_value(ResourceManager.Resource.POPULATION) && !prev_events.has(night_event):
			event = night_event
			prev_events.append(night_event)
			break
	if !event.empty():
			emit_signal("night_started", event)
	else:
		prev_events = []
		start_of_nighttime_tick()
	SystemManager.print("Night Started " + String(currentGamePlayTick))

func nighttime_tick():
	pass
	#TODO - ADD FUNCTIONALITY TO HAPPEN DURING NIGHTTIME

func debug_day_cycle_print():
	if debug_flag:
		if currentTick%60 == 0:
			if is_daytime():
				SystemManager.print("Day: " + String(currentGamePlayTick))
			else:
				SystemManager.print("Night: " + String(currentGamePlayTick))
		if currentTick%(60*(DAY_LENGTH+NIGHT_LENGTH)) == 0:
			SystemManager.print("NEW DAY: " + String(get_current_day()) + " <====================")

func update_attractiveness(value):
	SystemManager.data["player_data"]["attractiveness"] += value
	emit_signal("update_attractiveness")
	update_goblin_spawn_rate()
	
func get_attractiveness():
	return SystemManager.data["player_data"]["attractiveness"]
	
func update_goblin_spawn_rate():
	SystemManager.data["player_data"]["goblin_spawn_rate"] = 120 - ((get_attractiveness() / 2) + (50 * (1 - (ResourceManager.get_value(ResourceManager.Resource.POPULATION) / ResourceManager.get_value(ResourceManager.Resource.MAX_POPULATION)))))

func get_goblin_spawn_rate():
	return SystemManager.data["player_data"]["goblin_spawn_rate"]

onready var goblin_ticker = 0
func check_for_goblin_spawn():
	if ResourceManager.get_value(ResourceManager.Resource.POPULATION) < ResourceManager.get_value(ResourceManager.Resource.MAX_POPULATION):
		var sr = get_goblin_spawn_rate()
		SystemManager.print("goblin ticker: " + String(goblin_ticker))
		SystemManager.print("get_goblin_spawn_rate ticker: " + String(sr))
		if goblin_ticker >= sr:
			emit_signal("spawn_goblin")
			goblin_ticker = 0
		else:
			goblin_ticker += 1