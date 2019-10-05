extends Node2D

onready var navigation: Navigation2D = $Map/Navigation

var building = true
var selectedCharacter = null
var selectedEntity = null

func _ready():
	for character in $Map/Navigation/YSort/Characters.get_children():
		character.connect("selected", self, "select_character")
	
	$Map/Navigation/Map.setup($Map/Navigation/YSort/Entities, $Map/Navigation/YSort/Characters, self)

func select_character(character):
	selectedCharacter = character

func select_entity(entity):
	selectedEntity = entity
	
	move_character(selectedEntity.get_position())

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