extends Control

onready var anim_player = get_node("ColorRect/AnimationPlayer")
var tutorial_scene = preload("res://Scenes/tutorial.tscn")


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


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "close":
		scene_transition.change_scene("tutorial")
	if anim_name == "open":
		$AudioStreamPlayer2D.play()


func _on_AudioStreamPlayer2D_finished():
	$AudioStreamPlayer2D.play()
