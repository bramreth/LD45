extends TileMap

enum WallType {
	WALL = 11,
	SOUTH = 3,
	NORTH = 4,
	EAST = 5,
	WEST = 6,
	SOUTH_EAST = 7,
	SOUTH_WEST = 8,
	NORTH_EAST = 9
	NORTH_WEST = 10
}

var entitiesNode
var charactersNode
var gameRoot

# Called when the node enters the scene tree for the first time.
func setup(entities, characters, root):
	entitiesNode = entities
	charactersNode = characters
	gameRoot = root
	for cell in get_used_cells_by_id(1):
		add_hut(cell)

var hut = preload("res://Assets/Prefabs/BuildingMapEntity.tscn")

func add_hut(cell: Vector2):
	var newHut = hut.instance()
	entitiesNode.add_child(newHut)
	newHut.position = map_to_world(cell) + Vector2(0, cell_size.y/2+10)
	newHut.connect("selected", gameRoot, "select_entity")
