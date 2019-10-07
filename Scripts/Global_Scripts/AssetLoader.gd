extends Node

var assets = {}

func _ready():
	load_resource_icons()

func load_resource_icons():
	assets["resources"] = {}
	assets["resources"][ResourceManager.Resource.EGG] = load("res://Assets/Images/ui_icons/egg.png")
	assets["resources"][ResourceManager.Resource.FOOD] = load("res://Assets/Images/ui_icons/food.png")
	assets["resources"][ResourceManager.Resource.GOLD] = load("res://Assets/Images/ui_icons/gold.png")
	assets["resources"][ResourceManager.Resource.STONE] = load("res://Assets/Images/ui_icons/rock.png")
	assets["resources"][ResourceManager.Resource.WOOD] = load("res://Assets/Images/ui_icons/wood.png")
	assets["resources"][GameManager.Building.HUT] = load("res://Assets/Images/buildings/hut.png")
	assets["resources"][GameManager.Building.MESS] = load("res://Assets/Images/buildings/mess.png")
	assets["resources"][GameManager.Building.CAMP] = load("res://Assets/Images/buildings/camp.png")
	assets["resources"][GameManager.Building.HATCHERY] = load("res://Assets/Images/buildings/hatchery.png")
	assets["resources"][GameManager.Building.HUMAN_HUT] = load("res://Assets/Images/buildings/human_hut.png")	
	assets["resources"][GameManager.Building.RUBBLE] = load("res://Assets/Images/buildings/rubble_bg.png")
	