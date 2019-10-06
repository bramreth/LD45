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
	THE_PAINTING = 10
}

var itemSpawnLocations = {
	ResourceManager.Resource.EGG: [TILETYPE.BASE, TILETYPE.FOREST],
	ResourceManager.Resource.FOOD: [TILETYPE.BASE, TILETYPE.GRASS, TILETYPE.FOREST, TILETYPE.CAVE],
	ResourceManager.Resource.GOLD: [TILETYPE.BASE, TILETYPE.GRASS, TILETYPE.FOREST, TILETYPE.CAVE],
	ResourceManager.Resource.STONE: [TILETYPE.BASE, TILETYPE.CAVE],
	ResourceManager.Resource.WOOD: [TILETYPE.BASE, TILETYPE.FOREST]
}

var entitiesNode
var charactersNode
var gameRoot

func _ready():
	randomize()

func get_cell_size():
	return cell_size
	
func get_cell_val(cell):
	return get_cellv(cell)

func get_town_reach():
	var maxX = 10
	var maxY = 10
	
	for cell in get_used_cells_by_id(TILETYPE.BUILDING):
		if cell.x > maxX:
			maxX = cell.x
		if cell.y > maxY:
			maxY = cell.y
	
	return Vector2(maxX, maxY)

func get_random_spot_in_the_town():
	var townLimit = get_town_reach()
	var randomSpot = Vector2((rand_range(0,townLimit)), int(rand_range(0,townLimit)))
	return map_to_world(randomSpot) + Vector2(1, cell_size.y/2)
	

# Called when the node enters the scene tree for the first time.
func setup(entities, characters, root):
	entitiesNode = entities
	charactersNode = characters
	gameRoot = root
	
	WorldGenerator.generate_world(get_used_cells().max())
	draw_world()
	
	for cell in get_used_cells_by_id(TILETYPE.BUILDING):
		add_hut(cell)

var hut = preload("res://Assets/Prefabs/BuildingMapEntity.tscn")
var itemEntity = preload("res://Assets/Prefabs/ItemMapEntity.tscn")

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

func add_hut(cell: Vector2):
	var newHut = hut.instance()
	entitiesNode.add_child(newHut)
	newHut.position = map_to_world(cell) + Vector2(0, cell_size.y/2+10)
	newHut.connect("selected", gameRoot, "select_entity")
