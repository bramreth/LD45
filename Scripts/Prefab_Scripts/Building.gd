extends "res://Scripts/Prefab_Scripts/MapEntity.gd"

var buildingStats = {
	"capacity": {
		GameManager.Building.CAMP: 10,
		GameManager.Building.HUT: 5,
		GameManager.Building.SENTRY: 2,
		GameManager.Building.HATCHERY: 10,
		GameManager.Building.MESS: 10,
		GameManager.Building.RUBBLE: 3
	},
	"usage_time": {
		GameManager.Building.CAMP: 10,
		GameManager.Building.HUT: 3,
		GameManager.Building.SENTRY: 10,
		GameManager.Building.HATCHERY: 10,
		GameManager.Building.MESS: 10,
		GameManager.Building.RUBBLE: 30
	}
}

var occupants = {}

export(GameManager.Building) var building_type := GameManager.Building.HUT
var underConstruction = false
var currentCapacity = 0

func setup(finalType, wip):
	building_type = finalType
	underConstruction = wip
	
	if underConstruction:
		$MapEntity_Sprite.texture = AssetLoader.assets["resources"][GameManager.Building.RUBBLE]
	else:
		finish_construction()

func finish_construction():
	for goblin in get_tree().get_nodes_in_group("goblin"):
			goblin.construction_update(-1)
	$MapEntity_Sprite.texture = AssetLoader.assets["resources"][building_type]
	print($MapEntity_Sprite.texture)
	match building_type:
		GameManager.Building.HUT:
			ResourceManager.update_resource(ResourceManager.Resource.MAX_POPULATION, 5)
			print("hut built!!", ResourceManager.get_value(ResourceManager.Resource.MAX_POPULATION))
		GameManager.Building.RUBBLE:
			print("rubble built")

func _ready():
	._ready()
	type = GameManager.ENTITY_TYPE.BUILDING
	GameManager.connect("gameplay_tick", self, "gameplay_tick")

func is_at_capacity():
	if occupants.size() >= buildingStats["capacity"][building_type]:
		return true
	return false

func use_building(character):
	if underConstruction:
		if occupants.size() < buildingStats["capacity"][building_type]:
			occupants[character] = GameManager.currentGamePlayTick
			return true
		else:
			return false
	else:
		match building_type:
			GameManager.Building.HUT:
				if occupants.size() < buildingStats["capacity"][building_type]:
					occupants[character] = GameManager.currentGamePlayTick
					character.hide()
					return true
				else:
					return false

func gameplay_tick():
	if underConstruction:
		var buildProgress = 0
		for occupant in occupants:
			buildProgress += GameManager.currentGamePlayTick - occupants[occupant]
		if buildProgress > buildingStats["usage_time"][GameManager.Building.RUBBLE]:
			finish_construction()
			underConstruction = false
			for occupant in occupants:
				occupants.erase(occupant)
				occupant.finish_job()
	else:
		for occupant in occupants:
			if (GameManager.currentGamePlayTick - occupants[occupant] > buildingStats["usage_time"][building_type]):
				occupant.show()
				occupants.erase(occupant)
				occupant.finish_job()

func get_building_position():
	return position + $Entrance.position

func _unhandled_input(event):
	if mouseOver and event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed:
			get_tree().set_input_as_handled()
			emit_signal("selected", self)