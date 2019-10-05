extends Node2D

onready var navigation: Navigation2D = $Map/Navigation

var selectedCharacter = null
var selectedEntity = null

func _ready():
	for character in $Map/Navigation/YSort/Characters.get_children():
		character.connect("selected", self, "select_character")
	
	$Map/Navigation/Map.setup($Map/Navigation/YSort/Entities, $Map/Navigation/YSort/Characters, self)

func select_character(character):
	selectedCharacter = character

func selected_entity(entity):
	selectedEntity = entity
	
	move_character(selectedEntity.get_position())

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed:
			move_character(event.position)

func move_character(target):
	if selectedCharacter != null:
		var path = navigation.get_simple_path(selectedCharacter.position, target, false)
		selectedCharacter.move(path)