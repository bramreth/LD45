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
			move_character(event.position)

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
func _on_overlay_build(val):
	building = val
	$Map/Navigation/YSort/build_tool.visible = building
