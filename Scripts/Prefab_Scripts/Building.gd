extends "res://Scripts/Prefab_Scripts/MapEntity.gd"

var buildingStats = {
	"capacity": {
		GameManager.Building.CAMP: 10,
		GameManager.Building.HUT: 5,
		GameManager.Building.SENTRY: 2,
		GameManager.Building.HATCHERY: 10,
		GameManager.Building.MESS: 10
	},
	"usage_time": {
		GameManager.Building.CAMP: 10,
		GameManager.Building.HUT: 3,
		GameManager.Building.SENTRY: 10,
		GameManager.Building.HATCHERY: 10,
		GameManager.Building.MESS: 10
	}
}

var occupants = {}

export(GameManager.Building) var building_type := GameManager.Building.HUT
var currentCapacity = 0

func setup(resource):
	building_type = resource
	print("BRAM MARKER")
	print(resource)
#	$MapEntity_Sprite.texture = AssetLoader.assets["resources"][resourceType]
	match building_type:
		GameManager.Building.HUT:
			ResourceManager.update_resource(ResourceManager.Resource.MAX_POPULATION, 5)
			print("hut built!!", ResourceManager.get_value(ResourceManager.Resource.MAX_POPULATION))
	
func _ready():
	._ready()
	type = GameManager.ENTITY_TYPE.BUILDING
	GameManager.connect("gameplay_tick", self, "gameplay_tick")

func use_building(character):
	if occupants.size() < buildingStats["capacity"][building_type]:
		occupants[character] = GameManager.currentGamePlayTick
		character.hide()
		return true
	else:
		return false

func gameplay_tick():
	for occupant in occupants:
		if (GameManager.currentGamePlayTick - occupants[occupant] > buildingStats["usage_time"][building_type]):
			occupant.show()
			occupants.erase(occupant)
			occupant.finish_job()

func get_position():
	return position + $Entrance.position

func _unhandled_input(event):
	if mouseOver and event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed:
			get_tree().set_input_as_handled()
			emit_signal("selected", self)