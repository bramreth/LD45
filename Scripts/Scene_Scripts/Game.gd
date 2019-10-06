extends Node2D

onready var navigation: Navigation2D = $Map/Navigation

var building = false

var selectedCharacter = null
var selectedEntity = null
var selectedItem = null

#build tool sprites

var hut = preload("res://Assets/Images/debug_hut.png")
var blank = preload("res://Assets/Images/buildings/building_default.png")

onready var map = $Map/Navigation/Map

var mousePos = Vector2()

func _ready():
	GameManager.connect("spawn_items", self, "spawn_items")
	GameManager.connect("night_started", self, "remove_items_from_map")
	for character in $Map/Navigation/YSort/Characters.get_children():
		character.connect("selected", self, "select_character")
		character.connect("movement_done", self, "perform_contextual_action")
	for entity in $Map/Navigation/YSort/Entities.get_children():
		entity.connect("selected", self, "select_entity")
	
	#GameManager.start_dialog("tutorial")
	map.setup($Map/Navigation/YSort/Entities, $Map/Navigation/YSort/Characters, self)
	GameManager.start_game()

################################################################################################
# ITEM SPAWNING
################################################################################################
var itemSpawningThread: Thread
func spawn_items(items):
	itemSpawningThread = Thread.new()
	itemSpawningThread.start(self, "_thread_spawn_items", items)

func _thread_spawn_items(items):
	for item in items:
		if(items[item] > 0):
			map.spawn_items(item, items[item])

func remove_items_from_map():
	for child in $Map/Navigation/YSort/Entities.get_children():
		child.queue_free()
################################################################################################
# ENTITY SELECTION
################################################################################################
func select_character(character):
	if selectedCharacter:
		selectedCharacter.remove_highlight()
	selectedCharacter = character

func select_entity(entity):
	selectedEntity = entity 
	if selectedEntity.type == GameManager.ENTITY_TYPE.BUILDING:
		move_character(selectedEntity.get_position())
	elif selectedEntity.type == GameManager.ENTITY_TYPE.ITEM:
		move_character(selectedEntity.position)

func select_item(item):
	selectedItem = item
	move_character(selectedItem.position)

func perform_contextual_action():
	if selectedEntity != null:
		if selectedEntity.type == GameManager.ENTITY_TYPE.BUILDING:
			pass
		elif selectedEntity.type == GameManager.ENTITY_TYPE.ITEM:
			selectedEntity.pickup()
		selectedEntity = null

################################################################################################
# MOVEMENT
################################################################################################
func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed:
			move_character(get_global_mouse_position())

func move_character(target):
	print(target)
	if selectedCharacter != null:
		var path = navigation.get_simple_path(selectedCharacter.position, target, false)
		selectedCharacter.move(path)
		
		
#handle build tool
func _physics_process(delta):
	if building:
		var mouse_pos = get_global_mouse_position()
		
		var tile = $Map/Navigation/Map.world_to_map(mouse_pos)
		$Map/Navigation/YSort/build_tool.position =  $Map/Navigation/Map.map_to_world(tile) +Vector2(0, ($Map/Navigation/Map.cell_size.y/2)-172)
		if $Map/Navigation/Map.get_cell_val(tile) == 0 or $Map/Navigation/Map.get_cell_val(tile) == 1:
			$Map/Navigation/YSort/build_tool/Sprite.get_material().set_shader_param("color", Color("8c980101"))
		else:
			$Map/Navigation/YSort/build_tool/Sprite.get_material().set_shader_param("color", Color("8c299801"))	
		
# handle basic inputs	
func _input(event):
	if Input.is_action_just_pressed("scroll_out"):
		print("scroll")
		if $Camera2D.zoom.x < 2.0:
			$Camera2D.zoom +=  Vector2(0.1, 0.1)
		
	if Input.is_action_just_pressed("scroll_up"):
		print("scroll")
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
		
func _on_overlay_build(type, val):
	building = val
	match type:
		"hut":
			$Map/Navigation/YSort/build_tool/Sprite.texture = hut
			print("hut!")
		"blank":
			print("none")
			$Map/Navigation/YSort/build_tool/Sprite.texture = blank
			
	
	$Map/Navigation/YSort/build_tool.visible = building
	


func _on_MapEntity3_req_path():
	var me = $Map/Navigation/YSort/Characters/MapEntity3
	print($Map/Navigation/Map.world_to_map(me.position))
	var target = $Map/Navigation/Map.world_to_map(me.position)
	target.x += randi() % 2 - 1
	target.y += randi() % 2 - 1
	var path = navigation.get_simple_path($Map/Navigation/Map.world_to_map(me.position), target, false)
	me.move(path)
