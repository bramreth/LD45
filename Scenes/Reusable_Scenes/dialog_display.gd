extends Node2D

var dialog = {}
var current_dialog = {}
var dialog_index

onready var dialog_image_animation= get_node("dialog_menu/dialog_image/sprite_container/animated_sprite")
onready var dialog_container = get_node("dialog_menu/dialog_container")
onready var text_input = get_node("dialog_menu/text_input")
onready var action_button = get_node("action_button")

onready var scene_to_open = null
onready var lock_thread = false
onready var next_action = ""

func _ready():
	print("dialog ready")
	
func start_dialog(scene, _scene_to_open):
	scene_to_open = _scene_to_open
	dialog = StringManager.strings["dialog"][scene]
	if dialog != null:
		dialog_index = 0
		self.visible = true
		handle_dialog()
	else:
		print("Error loading dialog " + scene)

func kill_dialog():
	self.visible = false
	if scene_to_open != null:
		scene_transition.change_scene(scene_to_open)

func handle_dialog():
	var current_dialog_item = dialog[dialog_index]
	var state = current_dialog_item["state"]
	var text = current_dialog_item["text"]
	var animation = current_dialog_item["animation"] if !current_dialog_item["animation"].empty() else "default"
	var button_text = current_dialog_item["button_text"]
	next_action = current_dialog_item["next_action"]
	var duration = current_dialog_item["duration"]
	var text_speed = current_dialog_item["text_speed"] if TYPE_REAL == typeof(current_dialog_item["text_speed"]) else 0.03
	
	print("handle dialog--------------------")
	print("current_dialog_item: " + String(dialog_index))
	print("state: " + String(state))
	print("text: " + String(text))
	print("animation: " + String(animation))
	print("button_text: " + String(button_text))
	print("next_action: " + String(next_action))
	print("duration: " + String(duration))
	print("text_speed: " + String(text_speed))
	print("---------------------------------")
	print("")
	
	match state:
		"read":	
			text_input.visible = false
			startImageAnimation(animation)
			startDialog(text, text_speed)
			startButton(button_text)
		"input":
			startImageAnimation(animation)
			startInput()
			startButton(button_text)
		"read_input":
			startImageAnimation(animation)
			startDialog(text, text_speed)
			startInput()
			startButton(button_text)
		"cutscene":
			startCutScene(duration)
	
	
func startImageAnimation(animation):
	if animation.empty(): 
		return
	dialog_image_animation.animation = animation
	dialog_image_animation.playing = true
	
			
			
func startDialog(text, text_speed):
	var para = text if !text.empty() else ""
	dialog_container.visible = true	
	dialog_container.text = ""
	print(para)
	while para != "":
		lock_thread = true
		yield(get_tree().create_timer(text_speed), "timeout")
		dialog_container.text += para.left(1)
		para = para.right(1)
	lock_thread = false
	
	
func startInput():
	text_input.visible = true

func startButton(text):
	action_button.visible = true
	action_button.text = text
	
func startCutScene(duration):
	print(duration)
	if duration != null:
		self.visible = false
		yield(get_tree().create_timer(duration), "timeout")
		self.visible = true
		next_dialog()
		

func _on_action_button_pressed():
	if lock_thread:
		return
	match next_action:
		"next":
			next_dialog()
		"submit_name":
			if !text_input.text.empty():
				SystemManager.playerData["name"] = text_input.text
				next_dialog()
		"close":
			kill_dialog()
 
func next_dialog():
	dialog_index += 1
	handle_dialog()