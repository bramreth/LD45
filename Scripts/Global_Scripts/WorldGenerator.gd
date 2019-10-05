extends Node

# Instantiate
var noise = OpenSimplexNoise.new()
var worldSize:Vector2
var worldEnd:Vector2

func _ready():
	randomize()

func generate_world(maximum:Vector2):
	# Configure
	noise.seed = randi()
	noise.octaves = 4
	noise.period = 20.0
	noise.persistence = 0.8
	
	worldEnd = maximum

func get_noise_value(coord: Vector2):
	return noise.get_noise_2d(coord.x, coord.y)