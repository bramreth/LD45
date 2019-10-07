extends Node

signal start_dialog(scene)

signal spawn_items()
signal spawn_goblin()
signal spawn_enemies()

signal day_started()
signal night_started(event)
signal gameplay_tick()

var debug_flag = false

onready var night_events = SystemManager.data["events"]["night"]

const DAY_LENGTH = 120
const NIGHT_LENGTH = 40

var currentTick: int = 0 #1/60th seconds since started
var currentGamePlayTick: int = 0 #Seconds since started
var currentDay: int = 0 #number of day/night cycles since started

var tutorial = false

func set_tutorial(t_in):
	tutorial = t_in

func get_tutorial():
	return tutorial

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
	MESS,
	RUBBLE,
	HUMAN_HUT,
	THRONE_ROOM
}

enum Attractiveness {
	LOW,
	MEDIUM,
	HIGH,
	REALLY_HIGH	
}

enum Moral {
	PURE,
	GOOD,
	NICE,
	MEAN,
	BAD,
	EVIL,	
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
	
#	ResourceManager.update_resource(ResourceManager.Resource.WOOD, 30)
#	ResourceManager.update_resource(ResourceManager.Resource.STONE, 30)
#	ResourceManager.update_resource(ResourceManager.Resource.GOLD, 30)
#	ResourceManager.update_resource(ResourceManager.Resource.FOOD, 30)
	set_physics_process(true)

func is_daytime():
	if((currentGamePlayTick)%(DAY_LENGTH+NIGHT_LENGTH) < DAY_LENGTH):
		return true
	return false

func get_current_day():
	return currentTick/(60*(DAY_LENGTH+NIGHT_LENGTH))

func _physics_process(delta):
	currentGamePlayTick = currentTick/60
	#debug_day_cycle_print()
	
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
	spawn_items_list[ResourceManager.Resource.EGG] = randi()%32
	spawn_items_list[ResourceManager.Resource.FOOD] = randi()%35
	spawn_items_list[ResourceManager.Resource.GOLD] = randi()%24
	spawn_items_list[ResourceManager.Resource.STONE] = randi()%36+1
	spawn_items_list[ResourceManager.Resource.WOOD] = randi()%36+1
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

func update_moral(value):
	SystemManager.data["player_data"]["moral"] += value
	if SystemManager.data["player_data"]["moral"] > 100: SystemManager.data["player_data"]["moral"] = 100
	if SystemManager.data["player_data"]["moral"] < 0: SystemManager.data["player_data"]["moral"] = 0
	var moral_state = Attractiveness.PURE
	if SystemManager.data["player_data"]["moral"] >= 0 and SystemManager.data["player_data"]["moral"] < 16:
		moral_state = Attractiveness.GOOD
	if SystemManager.data["player_data"]["moral"] >= 16 and SystemManager.data["player_data"]["moral"] < 32:
		moral_state = Attractiveness.NICE
	if SystemManager.data["player_data"]["moral"] >= 32 and SystemManager.data["player_data"]["moral"] < 48:
		moral_state = Attractiveness.MEAN
	if SystemManager.data["player_data"]["moral"] >= 64 and SystemManager.data["player_data"]["moral"] < 80:
		moral_state = Attractiveness.BAD
	if SystemManager.data["player_data"]["moral"] >= 80:
		moral_state = Attractiveness.EVIL
	emit_signal("update_moral_image", moral_state)

func get_moral():
	return SystemManager.data["player_data"]["moral"]

func update_attractiveness(val):
	SystemManager.data["player_data"]["attractiveness"] += val
	if SystemManager.data["player_data"]["attractiveness"] > 100:
		SystemManager.data["player_data"]["attractiveness"] = 100

func get_attractiveness():
	return SystemManager.data["player_data"]["attractiveness"]
	
func update_goblin_spawn_rate():
	SystemManager.data["player_data"]["goblin_spawn_rate"] = 120 - ((get_attractiveness() / 3) + (get_happiness() / 3) + (33 * (1 - (ResourceManager.get_value(ResourceManager.Resource.POPULATION) / ResourceManager.get_value(ResourceManager.Resource.MAX_POPULATION)))))

func get_happiness():
	var leng = len(get_tree().get_nodes_in_group("goblins"))
	if leng < 1:
		return 100
	var hap = 0
	for item in get_tree().get_nodes_in_group("goblins"):
		#print(item)
		hap += item.happiness
	return int(hap/leng)

func get_goblin_spawn_rate():
	return SystemManager.data["player_data"]["goblin_spawn_rate"]

onready var goblin_ticker = 0
func check_for_goblin_spawn():
	if ResourceManager.get_value(ResourceManager.Resource.POPULATION) < ResourceManager.get_value(ResourceManager.Resource.MAX_POPULATION):
		var sr = get_goblin_spawn_rate()
		#print(sr)
		#goblin_ticker)
		if goblin_ticker >= sr:
			emit_signal("spawn_goblin")
			goblin_ticker = 0
		else:
			goblin_ticker += 1