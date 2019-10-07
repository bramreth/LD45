extends Control

onready var anim_player = get_node("ColorRect/AnimationPlayer")
#var tutorial_scene = preload("res://Scenes/tutorial.tscn")

var loadingTotal:int
var loadingProgress:int

var quips = [
	"Breaking all the glassware",
	"Fingerpainting the painting",
	"Hiding all the eggs",
	"Pissing off King Clement",
	"Hiding Higgledy Piggledy's hat and staff",
	"Pantsing the clan leader",
	"Eating the finest garbage",
	"Terrorizing the locals",
	"Accidentally torching the hartchery again",
	"Showing off the tarnished silver spoon collection",
	"Accidently slicing off a pinky while cooking and chucking it in the stew"
]

# Called when the node enters the scene tree for the first time.
func _ready():
	anim_player.play("open")
	scene_transition.connect("loading_scene", self, "set_loading_total")
	scene_transition.connect("loading_progress", self, "set_loading_progress")
	$MarginContainer/VBoxContainer/play_button.grab_focus()

func set_loading_total(total):
	anim_player.play("close")
	show_quip()
	loadingTotal = total;

func show_quip():
	$ColorRect/VBoxContainer/Quips.text = quips[randi()%quips.size()]
	yield(get_tree().create_timer(2.0), "timeout")
	show_quip()

func set_loading_progress(progress):
	$ColorRect/VBoxContainer/Progress.text = "Loading: " + String(int((float(progress)/float(loadingTotal))*100)) + "%"

func _on_play_button_pressed():
	GameManager.set_tutorial(true)
	scene_transition.background_load_scene("game")

func _on_quit_button_pressed():
	get_tree().quit()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "open":
		SystemManager.changeBackgroundMusic("ambient.wav")

func _on_test_button_pressed():
	GameManager.set_tutorial(false)
	scene_transition.background_load_scene("game")
