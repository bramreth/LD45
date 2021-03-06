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
var p3 ={}
var p4 ={}
	

var entitiesNode
var charactersNode
var buildingsNode
var gameRoot
var ySort

func _ready():
	randomize()
	p1[ResourceManager.Resource.WOOD] = 1
	p1[ResourceManager.Resource.STONE] = 2
	p1[ResourceManager.Resource.GOLD] = 0
	
	p2[ResourceManager.Resource.WOOD] = 2
	p2[ResourceManager.Resource.STONE] = 0
	p2[ResourceManager.Resource.GOLD] = 1
	
	p3[ResourceManager.Resource.WOOD] = 2
	p3[ResourceManager.Resource.STONE] = 1
	p3[ResourceManager.Resource.GOLD] = 0
	
	p4[ResourceManager.Resource.WOOD] = 2
	p4[ResourceManager.Resource.STONE] = 2
	p4[ResourceManager.Resource.GOLD] = 3
	
	prices[GameManager.Building.HUT] = p1
	prices[GameManager.Building.CAMP] = p2
	prices[GameManager.Building.MESS] = p3
	prices[GameManager.Building.HATCHERY] = p4
	

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
	if (cell == 0 or cell == 1 or cell == 2 or cell == 5 or cell == -1 or cell == 11) :
		return true
	elif not can_afford(type):
		return true
	else:
		return false
		
func can_afford(type):
#	print(ResourceManager.get_value(ResourceManager.Resource.WOOD) > 2)
	
	for item in prices[type].keys():
		if ResourceManager.get_value(item) < prices[type][item]:
			return false

	return true
	
	
# a dictionary containing plots of land that need building
var construction = {}

func build_building(tile, type):
	if check_can_build(tile, type):
		return
	set_cellv(tile, TILETYPE.CONSTRUCTION)
	for item in prices[type].keys():
		ResourceManager.update_resource(item, -prices[type][item])
	
	var newItem = buildEntity.instance()
	construction[tile] = [type, newItem]
	newItem.position = map_to_world(tile) + Vector2(1, cell_size.y/2)
	newItem.setup(type, true)
	newItem.connect("selected", gameRoot, "select_entity")
	ySort.call_deferred("add_child", newItem)
	remove_foliage(newItem.position)
#	for goblin in get_tree().get_nodes_in_group("goblin"):
#			goblin.construction_update(1)
	
	# we need this to create a construction tile that saves the texture and stats of the building
	# we want. then once a build is completed applies all of it's bonuses.
	
	# as a temporary measure I will make it so that construction happens immediately and predefined bonuses are
	# applied
	
	#the tile is empty, here we want to create a marker for a build event. we may want to change the tile to a new type
	# type 15 construction plot, then on finish change it to building
#	finish_construction(tile)
	
#func finish_construction(tile):
#	construction.erase(tile)
#	print(construction)
#	set_cellv(tile, TILETYPE.BUILDING)
#	construction[tile][1].setup(construction[tile][0])
#	print(construction)

var foliageCells = {}

# Called when the node enters the scene tree for the first time.
func setup(root, sorter):
	gameRoot = root
	ySort = sorter
	
	WorldGenerator.generate_world(get_used_cells().max())
	draw_world()
	
	for cell in get_used_cells_by_id(TILETYPE.HUMAN_WALL):
		add_wall(cell)
	for cell in get_used_cells_by_id(TILETYPE.HUMAN_BUILDING):
		add_building(cell)
	for cell in get_used_cells_by_id(TILETYPE.HUMAN_THRONE_ROOM):
		add_palace(cell)
	
	for cell in get_used_cells_by_id(TILETYPE.GRASS):
		add_grass(cell,false)
	for cell in get_used_cells_by_id(TILETYPE.FOREST):
		add_grass(cell,true)

var grass = preload("res://Assets/Prefabs/Grass.tscn")

func add_grass(cell, g):
	var newGrass = grass.instance()
	newGrass.position = map_to_world(cell) + Vector2(0, cell_size.y/2)
	newGrass.position += Vector2(rand_range(-100, 100), rand_range(-50, 500))
	ySort.add_child(newGrass)
	newGrass.setup(g)
	foliageCells[cell] = newGrass 

var hWall = preload("res://Assets/Prefabs/Wall.tscn")
var hHouse = preload("res://Assets/Prefabs/Human_House.tscn")
var hut = preload("res://Assets/Prefabs/BuildingMapEntity.tscn")
var itemEntity = preload("res://Assets/Prefabs/ItemMapEntity.tscn")
var buildEntity = preload("res://Assets/Prefabs/BuildingMapEntity.tscn")
var goblinEntity = preload("res://Assets/Prefabs/GoblinCharacterMapEntity.tscn")
var enemyEntity = preload("res://Assets/Prefabs/HumanEnemyMapEntity.tscn")

func add_wall(cell):
	var newWall = hWall.instance()
	newWall.position = map_to_world(cell) + Vector2(0, cell_size.y/2)
	ySort.add_child(newWall)

func add_building(cell):
	var newBuilding = hHouse.instance()
	newBuilding.position = map_to_world(cell) + Vector2(0, cell_size.y/2)
	if(get_cellv(cell-Vector2(0,1)) == TILETYPE.HUMAN_WALL):
		newBuilding.get_child(0).flip_h = true
	ySort.add_child(newBuilding)

func add_palace(cell):
	var newHut = hut.instance()
	newHut.setup(GameManager.Building.THRONE_ROOM, false)
	ySort.add_child(newHut)
	newHut.position = map_to_world(cell) + Vector2(0, cell_size.y/2+10)
	newHut.connect("selected", gameRoot, "select_entity")

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
		ySort.call_deferred("add_child", newItem)

func spawn_goblin():
	var validSpawns = get_used_cells()
	var spawn = validSpawns[randi()%validSpawns.size()]
	var newGoblin = goblinEntity.instance()
	newGoblin.position = map_to_world(spawn) + Vector2(1, cell_size.y/2)
	newGoblin.connect("selected", gameRoot, "select_character")
	newGoblin.connect("request_job_target", gameRoot, "provide_movement_target")
	ySort.call_deferred("add_child", newGoblin)
	
	ySort.call_deferred("join_clan")
	
func spawn_enemy():
	var validSpawns = get_used_cells()
	var spawn = validSpawns[randi()%validSpawns.size()]
	var newEnemy = enemyEntity.instance()
	newEnemy.position = map_to_world(spawn) + Vector2(1, cell_size.y/2)
	newEnemy.connect("selected", gameRoot, "select_character")
	ySort.call_deferred("add_child", newEnemy)

func remove_foliage(pos):
	var cell = world_to_map(pos)
	if foliageCells.has(cell):
		foliageCells[cell].hide()

#
#DEBUG BUILDING TESTING
#
func add_hut(cell: Vector2):
	var newHut = hut.instance()
	newHut.setup(GameManager.Building.HUT, false)
	ySort.add_child(newHut)
	newHut.position = map_to_world(cell) + Vector2(0, cell_size.y/2+10)
	newHut.connect("selected", gameRoot, "select_entity")
