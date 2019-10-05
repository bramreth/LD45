extends TileMap

enum TILETYPE {
	BASE = 0,
	WALL = 1,
	BUILDING = 2,
	GRASS = 3,
	FOREST = 4,
	CAVE = 5
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

func get_cell_size():
	return cell_size

# Called when the node enters the scene tree for the first time.
func setup(entities, characters, root):
	entitiesNode = entities
	charactersNode = characters
	gameRoot = root
	for cell in get_used_cells_by_id(TILETYPE.BUILDING):
		add_hut(cell)

var hut = preload("res://Assets/Prefabs/BuildingMapEntity.tscn")
var itemEntity = preload("res://Assets/Prefabs/ItemMapEntity.tscn")

func spawn_items(item, amount):
	var newItem = itemEntity.instance()
	var validSpawns = []
	for cellType in itemSpawnLocations[item]:
		validSpawns += get_used_cells_by_id(cellType)
	
	for i in range(amount):
		var spawn = validSpawns[randi()%validSpawns.size()]
		var spawnPosition = map_to_world(spawn) + Vector2(0, cell_size.y/2+10)
		newItem.resourceType = item
		entitiesNode.add_child(newItem)
		newItem.position = spawnPosition
		newItem.connect("selected", gameRoot, "select_entity")

func add_hut(cell: Vector2):
	var newHut = hut.instance()
	entitiesNode.add_child(newHut)
	newHut.position = map_to_world(cell) + Vector2(0, cell_size.y/2+10)
	newHut.connect("selected", gameRoot, "select_entity")
