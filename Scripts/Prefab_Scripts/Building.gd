extends "res://Scripts/Prefab_Scripts/MapEntity.gd"

var buildingStats = {
	"capacity": {
		GameManager.Building.CAMP: 1,
		GameManager.Building.HUT: 1,
		GameManager.Building.SENTRY: 2, #UNUSED
		GameManager.Building.HATCHERY: 10,#UNUSED
		GameManager.Building.MESS: 1,
		GameManager.Building.RUBBLE: 2
	},
	"usage_time": {
		GameManager.Building.CAMP: 3,
		GameManager.Building.HUT: 3,
		GameManager.Building.SENTRY: 10, #UNUSED
		GameManager.Building.HATCHERY: 10, #UNUSED
		GameManager.Building.MESS: 3,
		GameManager.Building.RUBBLE: 10
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
		add_to_group("construction_sites")
		$MapEntity_Sprite.texture = AssetLoader.assets["resources"][GameManager.Building.RUBBLE]
	else:
		finish_construction()

func finish_construction():
	$MapEntity_Sprite.texture = AssetLoader.assets["resources"][building_type]
	print($MapEntity_Sprite.texture)
	match building_type:
		GameManager.Building.HUT:
			ResourceManager.update_resource(ResourceManager.Resource.MAX_POPULATION, 5)
			GameManager.update_attractiveness(5)
		GameManager.Building.RUBBLE:
			print("rubble built")
		GameManager.Building.MESS:
			print("build mess")
			GameManager.update_attractiveness(5)
			# increase attractiveness
		GameManager.Building.CAMP:
			GameManager.update_attractiveness(10)
			print("build camp")
			#increase attractiveness

func _ready():
	._ready()
	type = GameManager.ENTITY_TYPE.BUILDING
	GameManager.connect("gameplay_tick", self, "gameplay_tick")

func is_at_capacity():
	if occupants.size() >= buildingStats["capacity"][building_type]:
		return true
	return false

func inform_goblins_this_is_no_longer_valid_target_for_job():
	for goblin in get_tree().get_nodes_in_group("goblin"):
		goblin.is_this_current_target(self)

func use_building(character):
	if underConstruction:
		if occupants.size() < buildingStats["capacity"][GameManager.Building.RUBBLE]:
			occupants[character] = GameManager.currentGamePlayTick
			if occupants.size() == buildingStats["capacity"][building_type]:
				inform_goblins_this_is_no_longer_valid_target_for_job()
	else:
		if character.type == GameManager.ENTITY_TYPE.PLAYER:
			return occupants 
		match building_type:
			GameManager.Building.HUT, GameManager.Building.MESS:
				if occupants.size() < buildingStats["capacity"][building_type]:
					occupants[character] = GameManager.currentGamePlayTick
					character.hide()
			GameManager.Building.CAMP:
				if occupants.size() < buildingStats["capacity"][building_type]:
					occupants[character] = GameManager.currentGamePlayTick
	
		if occupants.size() == buildingStats["capacity"][building_type]:
			inform_goblins_this_is_no_longer_valid_target_for_job()


func gameplay_tick():
	if underConstruction:
		var buildProgress = 0
		for occupant in occupants:
			buildProgress += GameManager.currentGamePlayTick - occupants[occupant]
		#print(String(building_type) + ": " + String(occupants.size()) + " - " + String(buildProgress) + "/" + String(buildingStats["usage_time"][GameManager.Building.RUBBLE]))
		if buildProgress > buildingStats["usage_time"][GameManager.Building.RUBBLE]:
			finish_construction()
			inform_goblins_this_is_no_longer_valid_target_for_job()
			remove_from_group("construction_sites")
			underConstruction = false
			for occupant in occupants:
				occupants.erase(occupant)
				if occupant.type == GameManager.ENTITY_TYPE.GOBLIN:
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