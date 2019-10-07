extends Node2D

onready var navigation: Navigation2D = $Map/Navigation

var building = false
var current_building = null

var selectedCharacter = null
var selectedEntity = null
var selectedItem = null

#build tool sprites

var hut = preload("res://Assets/Images/debug_hut.png")
var blank = preload("res://Assets/Images/buildings/building_default.png")

onready var map = $Map/Navigation/Map
onready var player = $Map/Navigation/YSort/Player

var mousePos = Vector2()

func _ready():
	GameManager.connect("spawn_items", self, "spawn_items")
	GameManager.connect("spawn_goblin", self, "spawn_goblin")
	GameManager.connect("night_started", self, "start_night")
	GameManager.connect("night_started", self, "remove_items_from_map")
	
	for character in get_tree().get_nodes_in_group("goblins"):
		character.connect("request_job_target", self, "provide_movement_target")
		character.connect("selected", self, "select_character")
		
	for character in get_tree().get_nodes_in_group("enemies"):
		character.connect("request_job_target", self, "provide_movement_target")
		character.connect("selected", self, "select_character")
		character.connect("start_combat", self, "start_combat")
	
	for building in get_tree().get_nodes_in_group("buildings"):
		building.connect("selected", self, "select_entity")
		
	for item in get_tree().get_nodes_in_group("items"):
		item.connect("selected", self, "select_entity")
	
	player.connect("movement_done", self, "perform_contextual_action")
	player.connect("selected", self, "select_character")
	
	if GameManager.get_tutorial():
		GameManager.start_dialog("tutorial")
	map.setup(self, $Map/Navigation/YSort)
	GameManager.start_game()
	
################################################################################################
# SPAWNING
################################################################################################
var itemSpawningThread: Thread
func spawn_items(items):
	itemSpawningThread = Thread.new()
	itemSpawningThread.start(self, "_thread_spawn_items", items)

func _thread_spawn_items(items):
	for item in items:
		if(items[item] > 0):
			map.spawn_items(item, items[item])
	call_deferred("items_spawned")

func items_spawned():
	itemSpawningThread.wait_to_finish()
	
var buildingSpawningThread: Thread
func spawn_buildings(items):
	buildingSpawningThread = Thread.new()
	buildingSpawningThread.start(self, "_thread_spawn_items", items)

func _thread_spawn_building(items):
	for item in items:
		if(items[item] > 0):
			map.spawn_items(item, items[item])
	call_deferred("items_spawned")

func building_spawned():
	buildingSpawningThread.wait_to_finish()

var goblinSpawningThread: Thread
func spawn_goblin():
	goblinSpawningThread = Thread.new()
	goblinSpawningThread.start(self, "_thread_spawn_goblin")

func _thread_spawn_goblin(userdata):
	map.spawn_goblin()
	call_deferred("goblin_spawned")

func goblin_spawned():
	goblinSpawningThread.wait_to_finish()

var enemySpawningThread: Thread
func spawn_enemies(amount):
	print("spawning enemies: " + String(amount))
	enemySpawningThread = Thread.new()
	enemySpawningThread.start(self, "_thread_spawn_enemies", amount)

func _thread_spawn_enemies(amount):
	for i in range(amount):
		map.spawn_enemy()
	call_deferred("enemy_spawned")

func enemy_spawned():
	enemySpawningThread.wait_to_finish()

var combatSpawningThread:Thread
var combat = preload("res://Assets/Prefabs/CombatMapEntity.tscn")
func start_combat(target, attacker):
	combatSpawningThread = Thread.new()
	combatSpawningThread.start(self, "_thread_spawn_combat", [target, attacker])

func _thread_spawn_combat(startingCombatents):
	var newCombat = combat.instance()
	newCombat.start_combat(startingCombatents)
	newCombat.position = startingCombatents[1].position
	$Map/Navigation/YSort.call_deferred("add_child", newCombat)
	call_deferred("combat_spawned")

func combat_spawned():
	combatSpawningThread.wait_to_finish()

func remove_items_from_map():
	
	for child in get_tree().get_nodes_in_group("items"):
		if not child.pickedUp:
			child.queue_free()

func _exit_tree():
	if itemSpawningThread != null:
		itemSpawningThread.wait_to_finish()
	if buildingSpawningThread != null:
		buildingSpawningThread.wait_to_finish
	if goblinSpawningThread != null:
		goblinSpawningThread.wait_to_finish()
	if enemySpawningThread != null:
		enemySpawningThread.wait_to_finish()
	if combatSpawningThread != null:
		combatSpawningThread.wait_to_finish()

################################################################################################
# ENTITY SELECTION
################################################################################################
func select_character(character):
	if selectedCharacter:
		selectedCharacter.remove_highlight()
	selectedCharacter = character
	selectedCharacter.highlight()
	if selectedCharacter.type == GameManager.ENTITY_TYPE.GOBLIN or  selectedCharacter.type == GameManager.ENTITY_TYPE.PLAYER:
		$Camera2D/CanvasLayer/overlay.show_goblin(character.get_details())

func select_entity(entity):
	stop_construction()
	
	selectedEntity = entity 
	if selectedEntity.type == GameManager.ENTITY_TYPE.BUILDING:
		move_character(selectedEntity.get_building_position())
	elif selectedEntity.type == GameManager.ENTITY_TYPE.ITEM:
		move_character(selectedEntity.position)

func perform_contextual_action(character):
	if selectedEntity != null:
		if character.type == GameManager.ENTITY_TYPE.PLAYER:
			if selectedEntity.type == GameManager.ENTITY_TYPE.BUILDING:
				if selectedEntity.underConstruction:
					selectedEntity.use_building(player)
				else:
					print("Occupants: " + String(selectedEntity.use_building(player)))
			elif selectedEntity.type == GameManager.ENTITY_TYPE.ITEM:
				selectedEntity.pickup()
				selectedEntity = null

func stop_construction():
	if selectedEntity != null:
		if selectedEntity.type == GameManager.ENTITY_TYPE.BUILDING:
			if selectedEntity.underConstruction:
				selectedEntity.occupants.erase(player)
################################################################################################
# PLAYER MOVEMENT
################################################################################################
func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed:
			stop_building()
			stop_construction()
			selectedEntity = null
			get_tree().set_input_as_handled()
			move_character(get_global_mouse_position())
		if event.button_index == BUTTON_LEFT and event.pressed && building:
			var cell = $Map/Navigation/Map.world_to_map(get_global_mouse_position())
			$Map/Navigation/Map.build_building(cell, current_building)
			build_can_color()

func get_path_between_points(start, end):
		return navigation.get_simple_path(start, end, false)

func move_character(target):
	var path = get_path_between_points(player.position, target)
	player.move(path)
	stop_construction()
	if selectedCharacter != player:
		select_character(player)
################################################################################################
# AI MOVEMENT
################################################################################################
func get_closest_building_by_type(type, position):
	var distance = null
	var closestBuilding = null
	for build in get_tree().get_nodes_in_group("buildings"):
		if build.building_type == type and !build.is_at_capacity() and !build.underConstruction:
			if distance == null or position.distance_to(build.get_building_position()) < distance:
				distance = position.distance_to(build.get_building_position())
				closestBuilding = build
	return closestBuilding

func get_closest_construction_site(position):
	var distance = null
	var closestBuilding = null
	for build in get_tree().get_nodes_in_group("buildings"):
		if !build.is_at_capacity() and build.underConstruction:
			if distance == null or position.distance_to(build.get_building_position()) < distance:
				distance = position.distance_to(build.get_building_position())
				closestBuilding = build
	return closestBuilding

func get_closest_combat(position):
	var distance = null
	var closestCombat = null
	for combat in get_tree().get_nodes_in_group("combat_sites"):
		if distance == null or position.distance_to(combat.position) < distance:
			distance = position.distance_to(combat.position)
			closestCombat = combat
	return closestCombat

func get_closest_goblin(position):
	var distance = null
	var closestGoblin = null
	for goblin in get_tree().get_nodes_in_group("goblins"):
		if distance == null or position.distance_to(goblin.position) < distance:
			distance = position.distance_to(goblin.position)
			closestGoblin = goblin
	return closestGoblin

func get_closest_item(position):
	var distance = null
	var closestItem = null
	for item in get_tree().get_nodes_in_group("items"):
		if !item.pickedUp:
			if distance == null or position.distance_to(item.position) < distance:
				distance = position.distance_to(item.position)
				closestItem = item
	return closestItem

func provide_movement_target(character, job):
	call(("ai_" + job), character)

func ai_fight(character):
	var combat = get_closest_combat(character.position)
	var path = null
	if combat != null:
		path = get_path_between_points(character.position, combat.position)
	character.handle_job(path, combat)

func ai_wander(character):
	var path = get_path_between_points(character.position, map.get_random_spot_in_the_town())
	character.handle_job(path, null)

func ai_rest(character):
	var restStop = get_closest_building_by_type(GameManager.Building.HUT, character.position)
	var path = null
	if restStop != null:
		path = get_path_between_points(character.position, restStop.get_building_position())
	character.handle_job(path, restStop)

func ai_relax(character):
	var camp = get_closest_building_by_type(GameManager.Building.CAMP, character.position)
	var path = null
	if camp != null:
		path = get_path_between_points(character.position, camp.get_building_position())
	character.handle_job(path, camp)

func ai_eat(character):
	var mess = get_closest_building_by_type(GameManager.Building.MESS, character.position)
	var path = null
	if mess != null:
		path = get_path_between_points(character.position, mess.get_building_position())
	character.handle_job(path, mess)

func ai_build(character):
	var buildSite = get_closest_construction_site(character.position)
	var path = null
	if buildSite != null:
		path = get_path_between_points(character.position, buildSite.get_building_position())
	character.handle_job(path, buildSite)

func ai_gather(character):
	var itemLocation = get_closest_item(character.position)
	var path = null
	if itemLocation != null:
		path = get_path_between_points(character.position, itemLocation.position)
	character.handle_job(path, itemLocation)

func ai_join(character):
	match character.type:
		GameManager.ENTITY_TYPE.GOBLIN:
			SystemManager.print("GOBLIN SPAWNED AT: " + String(character.position))
			ResourceManager.update_resource(ResourceManager.Resource.POPULATION, 1)

func ai_attack(character):
	var goblin = get_closest_goblin(character.position)
	var path = null
	if goblin != null:
		goblin.stun()
		path = get_path_between_points(character.position, goblin.position)
	character.handle_job(path, goblin)
################################################################################################
# CAMERA
################################################################################################
#handle build tool
func _physics_process(delta):
	if building:
		var mouse_pos = get_global_mouse_position()
		
		var tile = $Map/Navigation/Map.world_to_map(mouse_pos)
		$Map/Navigation/YSort/build_tool.position =  $Map/Navigation/Map.map_to_world(tile) +Vector2(0, ($Map/Navigation/Map.cell_size.y/2)-172)
		var cell = $Map/Navigation/Map.get_cell_val(tile)
		if $Map/Navigation/Map.check_can_build(tile, current_building):
			
			$Map/Navigation/YSort/build_tool/Sprite.get_material().set_shader_param("color", Color("8c980101"))
		else:
			$Map/Navigation/YSort/build_tool/Sprite.get_material().set_shader_param("color", Color("8c299801"))	
		
# handle basic inputs	
func _input(event):
	if Input.is_action_just_pressed("scroll_out"):
		if $Camera2D.zoom.x < 3.0:
			$Camera2D.zoom +=  Vector2(0.1, 0.1)
		
	if Input.is_action_just_pressed("scroll_up"):
		if $Camera2D.zoom.x > 0.3:
			$Camera2D.zoom -=  Vector2(0.1, 0.1)
	
	if Input.is_action_just_pressed("middle_mouse"):
		mousePos = get_global_mouse_position()
	if Input.is_action_just_released("middle_mouse"):
		mousePos = null
		
	
			
	

const leftLimit: int = -3300*4
const rightLimit: int = 3100*4
const topLimit: int = -80*4
const bottomLimit: int = 3120*4

func _process(delta):
	if Input.is_action_pressed("ui_left") and $Camera2D.position.x > leftLimit:
		$Camera2D.position.x = lerp($Camera2D.position.x, $Camera2D.position.x - (50), 20*$Camera2D.zoom.x* delta)
		
	if Input.is_action_pressed("ui_right") and $Camera2D.position.x < rightLimit:
		$Camera2D.position.x = lerp($Camera2D.position.x, $Camera2D.position.x + (50), 20*$Camera2D.zoom.x* delta)

	if Input.is_action_pressed("ui_up") and $Camera2D.position.y > topLimit:
		$Camera2D.position.y = lerp($Camera2D.position.y, $Camera2D.position.y - (50), 20*$Camera2D.zoom.y* delta)
		
	if Input.is_action_pressed("ui_down") and $Camera2D.position.y < bottomLimit:
		$Camera2D.position.y = lerp($Camera2D.position.y, $Camera2D.position.y + (50), 20*$Camera2D.zoom.x* delta)

	
	if mousePos:
		# and $Camera2D.position.x > -500 and $Camera2D.position.x < 500 and $Camera2D.position.y > -300and $Camera2D.position.y < 300
		var dif = mousePos - get_global_mouse_position()
		if $Camera2D.position.x <= leftLimit and dif.x < 0:
			return
		if $Camera2D.position.x >= rightLimit and dif.x > 0:
			return
		if $Camera2D.position.y <= topLimit and dif.y < 0:
			return
		if $Camera2D.position.y >= bottomLimit and dif.y > 0:
			return
			
		$Camera2D.position += (mousePos - get_global_mouse_position()) * delta * $Camera2D.zoom * 5.0
		
func stop_building():
	building = false
	$Map/Navigation/YSort/build_tool.visible = building
	$Camera2D/CanvasLayer/overlay.no_build()
	
func _on_overlay_build(type, val):
	building = val
	current_building = type
	$Map/Navigation/YSort/build_tool/Sprite.texture = AssetLoader.assets["resources"][current_building]
#		"blank":
#			print("none")
#			$Map/Navigation/YSort/build_tool/Sprite.texture = blank
			
	
	$Map/Navigation/YSort/build_tool.visible = building
	$Map/Navigation/YSort/build_tool/Sprite/ColorRect/wood.text = str($Map/Navigation/Map.prices[current_building][ResourceManager.Resource.WOOD])
	$Map/Navigation/YSort/build_tool/Sprite/ColorRect/stone.text = str($Map/Navigation/Map.prices[current_building][ResourceManager.Resource.STONE])
	$Map/Navigation/YSort/build_tool/Sprite/ColorRect/gold.text = str($Map/Navigation/Map.prices[current_building][ResourceManager.Resource.GOLD])
	build_can_color()
	
func build_can_color():
	if ResourceManager.get_value(ResourceManager.Resource.WOOD) < $Map/Navigation/Map.prices[current_building][ResourceManager.Resource.WOOD]:
			$Map/Navigation/YSort/build_tool/Sprite/ColorRect/wood.modulate = Color("ff0000")
	else:
		$Map/Navigation/YSort/build_tool/Sprite/ColorRect/wood.modulate = Color("ffffff")
	if ResourceManager.get_value(ResourceManager.Resource.STONE) < $Map/Navigation/Map.prices[current_building][ResourceManager.Resource.STONE]:
			$Map/Navigation/YSort/build_tool/Sprite/ColorRect/stone.modulate = Color("ff0000")
	else:
		$Map/Navigation/YSort/build_tool/Sprite/ColorRect/stone.modulate = Color("ffffff")
	if ResourceManager.get_value(ResourceManager.Resource.GOLD) < $Map/Navigation/Map.prices[current_building][ResourceManager.Resource.GOLD]:
			$Map/Navigation/YSort/build_tool/Sprite/ColorRect/gold.modulate = Color("ff0000")
	else:
		$Map/Navigation/YSort/build_tool/Sprite/ColorRect/gold.modulate = Color("ffffff")
################################################################################################
# EVENT HANDLING
################################################################################################
func start_night(event):
	remove_items_from_map()
	if event != null:
		GameManager.start_dialog(event["dialog"])
		spawn_enemies(event["num_of_enemies"])
	
	