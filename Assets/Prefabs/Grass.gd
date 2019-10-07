extends Node2D

func setup(grass):
	if grass:
		$Sprite.texture = AssetLoader.assets["grass"]["grass"][randi()%3]
	else:
		$Sprite.texture = AssetLoader.assets["grass"]["tree"]