extends Sprite

var path: PoolVector2Array
var isMoving: bool = false
export var speed := 250

func _ready():
	set_process(false)

func move(newPath: PoolVector2Array):
	path = newPath
	isMoving = true
	set_process(true)

func _process(delta):
	if !path:
		isMoving = false
		set_process(false)
	if path.size() > 0:
		var d: float = position.distance_to(path[0])
		if d > 10:
			position = position.linear_interpolate(path[0], (speed * delta)/d)
		else:
			path.remove(0)