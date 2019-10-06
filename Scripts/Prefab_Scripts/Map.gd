extends TileMap

enum TILETYPE {
	BASE = 0,
	WALL = 1,
	BUILDING = 2,
	GRASS = 3,
	FOREST = 4,
	CAVE = 5,
	HUMAN_WALL = 6,
	HUMAN_STREET = 7,
	HUMAN_BUILDING = 8,
	HUMAN_THRONE_ROOM = 9,
	THE_PAINTING = 10,
	CONSTRUCTION = 11
}

var itemSpawnLocations = {
	ResourceManager.Resource.EGG: [TILETYPE.BASE, TILETYPE.FOREST],
	ResourceManager.Resource.FOOD: [TILETYPE.BASE, TILETYPE.GRASS, TILETYPE.FOREST, TILETYPE.CAVE],
	ResourceManager.Resource.GOLD: [TILETYPE.BASE, TILETYPE.GRASS, TILETYPE.FOREST, TILETYPE.CAVE],
	ResourceManager.Resource.STONE: [TILETYPE.BASE, TILETYPE.CAVE],
	ResourceManager.Resource.WOOD: [TILETYPE.BASE, TILETYPE.FOREST]
}

var prices = {}
var p1 = {}
var p2 ={}
	

var entitiesNode
var charactersNode
var buildingsNode
var gameRoot

func _ready():
	randomize()
	p1[ResourceManager.Resource.WOOD] = 1
	p1[ResourceManager.Resource.STONE] = 1
	p1[ResourceManager.Resource.GOLD] = 0
	
	p2[ResourceManager.Resource.WOOD] = 2
	p2[ResourceManager.Resource.STONE] = 4
	p2[ResourceManager.Resource.GOLD] = 0
	
	prices["hut"] = p2
	prices["blank"] = p1

func get_cell_size():
	return cell_size
	
func get_cell_val(cell):
	return get_cellv(cell)

func get_town_reach():
	var maxX = 7
	var maxY = 7
	
	for cell in get_used_cells_by_id(TILETYPE.BUILDING):
		if cell.x > maxX:
			maxX = cell.x
		if cell.y > maxY:
			maxY = cell.y
	
	return Vector2(maxX, maxY)

func get_random_spot_in_the_town():
	var townLimit = get_town_reach()
	var randomSpot = Vector2(int(rand_range(0,townLimit.x)), int(rand_range(0,townLimit.y)))
	return map_to_world(randomSpot) + Vector2(1, cell_size.y/2)
	
func check_can_build(tile, type):
	var cell = get_cellv(tile)
	if (cell == 0 or cell == 1 or cell == 2 or cell == 5 or cell == -1) :
		return true
	elif not can_afford(type):
		return true
	else:
		return false
		
func can_afford(type):
#	print(ResourceManager.get_value(ResourceManager.Resource.WOOD) > 2)
	
	for item in prices[type].keys():
		print(item)
		if ResourceManager.get_value(item) < prices[type][item]:
			return false

	return true
	
func build_building(tile, type):
	if check_can_build(tile, type):
		return
	set_cellv(tile, TILETYPE.BUILDING)
	for item in prices[type].keys():
		ResourceManager.update_resource(item, -prices[type][item])
	var newItem = buildEntity.instance()
	newItem.setup(type)
	newItem.position = map_to_world(tile) + Vector2(1, cell_size.y/2)
	#newItem.position += Vector2(0, cell_size.y/2)
#	newItem.connect("selected", gameRoot, "select_entity")
	buildingsNode.call_deferred("add_child", newItem)



	

# Called when the node enters the scene tree for the first time.
func setup(entities, characters, buildings, root):
	entitiesNode = entities
	charactersNode = characters
	buildingsNode = buildings
	gameRoot = root
	
	WorldGenerator.generate_world(get_used_cells().max())
	draw_world()
	
	for cell in get_used_cells_by_id(TILETYPE.BUILDING):
		add_hut(cell)

var hut = preload("res://Assets/Prefabs/BuildingMapEntity.tscn")
var itemEntity = preload("res://Assets/Prefabs/ItemMapEntity.tscn")
var buildEntity = preload("res://Assets/Prefabs/BuildingMapEntity.tscn")
var goblinEntity = preload("res://Assets/Prefabs/GoblinCharacterMapEntity.tscn")

func draw_world():
	for cell in get_used_cells_by_id(TILETYPE.BASE):
		var noiseVal = WorldGenerator.get_noise_value(cell)
		if noiseVal <= 0:
			set_cellv(cell, TILETYPE.GRASS)
		else:
			set_cellv(cell, TILETYPE.FOREST)

func spawn_items(item, amount):
	var validSpawns = []
	for cellType in itemSpawnLocations[item]:
		validSpawns += get_used_cells_by_id(cellType)
	
	for i in range(amount):
		var spawn = validSpawns[randi()%validSpawns.size()]
		var newItem = itemEntity.instance()
		newItem.setup(item)
		newItem.position = map_to_world(spawn) + Vector2(1, cell_size.y/2)
		#newItem.position += Vector2(0, cell_size.y/2)
		newItem.connect("selected", gameRoot, "select_entity")
		entitiesNode.call_deferred("add_child", newItem)

func spawn_goblin():
	var validSpawns = get_used_cells()
	var spawn = validSpawns[randi()%validSpawns.size()]
	var newGoblin = goblinEntity.instance()
	newGoblin.position = map_to_world(spawn) + Vector2(1, cell_size.y/2)
	newGoblin.connect("selected", gameRoot, "select_character")
	newGoblin.connect("request_job_target", gameRoot, "provide_movement_target")
	charactersNode.call_deferred("add_child", newGoblin)
	newGoblin.call_deferred("join_clan")
	

func add_hut(cell: Vector2):
	var newHut = hut.instance()
	entitiesNode.add_child(newHut)
	newHut.position = map_to_world(cell) + Vector2(0, cell_size.y/2+10)
	newHut.connect("selected", gameRoot, "select_entity")
