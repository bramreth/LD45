extends Node2D

onready var navigation: Navigation2D = $Map/Navigation

var path : PoolVector2Array
var goal : Vector2

var selectedCharacter = null

func _ready():
	for character in $Map/Navigation/YSort/Characters.get_children():
		character.connect("selected", self, "select_character")

func select_character(character):
	selectedCharacter = character

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed and selectedCharacter != null:
			goal = event.position
			path = navigation.get_simple_path(selectedCharacter.position, goal, false)
			selectedCharacter.move(path)