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

# Called when the node enters the scene tree for the first time.
func _ready():
	for cell in get_used_cells_by_id(WallType.WALL):
		set_wall_type(cell)

func set_wall_type(cell: Vector2):
	pass
