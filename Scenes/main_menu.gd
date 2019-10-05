extends Control

onready var anim_player = get_node("ColorRect/AnimationPlayer")
# Called when the node enters the scene tree for the first time.
func _ready():
	anim_player.play("open")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_play_button_pressed():
	anim_player.play("close")


func _on_quit_button_pressed():
	get_tree().quit()
