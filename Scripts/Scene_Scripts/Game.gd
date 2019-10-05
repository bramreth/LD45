extends Node2D

onready var navigation: Navigation2D = $Map/Navigation

var building = false

var selectedCharacter = null
var selectedEntity = null
var selectedItem = null

func _ready():
	for character in $Map/Navigation/YSort/Characters.get_children():
		character.connect("selected", self, "select_character")
		character.connect("movement_done", self, "perform_contextual_action")
	
	$Map/Navigation/Map.setup($Map/Navigation/YSort/Entities, $Map/Navigation/YSort/Characters, self)

################################################################################################
# ENTITY SELECTION
################################################################################################
func select_character(character):
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
	if selectedEntity.type == GameManager.ENTITY_TYPE.BUILDING:
		pass
	elif selectedEntity.type == GameManager.ENTITY_TYPE.ITEM:
		selectedEntity.pickup()

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
		$Map/Navigation/YSort/build_tool.position =  $Map/Navigation/Map.map_to_world(tile) +Vector2(0, $Map/Navigation/Map.cell_size.y/2)
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
			
func _process(delta):
	if Input.is_action_pressed("ui_left") and $Camera2D.position.x > -500:
		$Camera2D.position.x = lerp($Camera2D.position.x, $Camera2D.position.x - (20), 20*$Camera2D.zoom.x* delta)
		
	if Input.is_action_pressed("ui_right")and $Camera2D.position.x < 500:
		$Camera2D.position.x = lerp($Camera2D.position.x, $Camera2D.position.x + (20), 20*$Camera2D.zoom.x* delta)

	if Input.is_action_pressed("ui_up")and $Camera2D.position.y > -300:
		$Camera2D.position.y = lerp($Camera2D.position.y, $Camera2D.position.y - (20), 20*$Camera2D.zoom.y* delta)	
		
	if Input.is_action_pressed("ui_down")and $Camera2D.position.y < 300:
		$Camera2D.position.y = lerp($Camera2D.position.y, $Camera2D.position.y + (20), 20*$Camera2D.zoom.x* delta)			
	
func _on_overlay_build(val):
	building = val
	$Map/Navigation/YSort/build_tool.visible = building
