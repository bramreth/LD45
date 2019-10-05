extends TileMap

enum TILETYPE {
	BASE = 0,
	WALL = 1,
	BUILDING = 2,
	GRASS = 3,
	FOREST = 4,
	CAVE = 5
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

func add_hut(cell: Vector2):
	var newHut = hut.instance()
	entitiesNode.add_child(newHut)
	newHut.position = map_to_world(cell) + Vector2(0, cell_size.y/2+10)
	newHut.connect("selected", gameRoot, "select_entity")
