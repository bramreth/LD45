extends Node

var assets = {}

func _ready():
	load_resource_icons()

func load_resource_icons():
	assets["resources"] = {}
	assets["items"] = {}
	assets["grass"] = {}
	assets["grass"]["grass"] = [load("res://Assets/Images/buildings/grass_1.png"), load("res://Assets/Images/buildings/grass_2.png"), load("res://Assets/Images/buildings/grass_3.png")]
	assets["grass"]["tree"] = load("res://Assets/Images/buildings/tree.png")
	assets["items"][ResourceManager.Resource.EGG] = load("res://Assets/Images/ui_icons/egg.png")
	assets["items"][ResourceManager.Resource.FOOD] = load("res://Assets/Images/ui_icons/food.png")
	assets["items"][ResourceManager.Resource.GOLD] = load("res://Assets/Images/ui_icons/gold.png")
	assets["items"][ResourceManager.Resource.STONE] = load("res://Assets/Images/ui_icons/rock.png")
	assets["items"][ResourceManager.Resource.WOOD] = load("res://Assets/Images/ui_icons/wood.png")
	assets["resources"][GameManager.Building.HUT] = load("res://Assets/Images/buildings/hut.png")
	assets["resources"][GameManager.Building.MESS] = load("res://Assets/Images/buildings/mess.png")
	assets["resources"][GameManager.Building.CAMP] = load("res://Assets/Images/buildings/camp.png")
	assets["resources"][GameManager.Building.HATCHERY] = load("res://Assets/Images/buildings/hatchery.png")
	assets["resources"][GameManager.Building.HUMAN_HUT] = load("res://Assets/Images/buildings/human_hut.png")	
	assets["resources"][GameManager.Building.RUBBLE] = load("res://Assets/Images/buildings/rubble_bg.png")
	assets["resources"][GameManager.Building.THRONE_ROOM] = load("res://Assets/Images/buildings/throne_room.png")
	