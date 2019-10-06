extends Node2D


signal show_overlay()
signal hide_overlay()

var dialog = {}
var current_dialog = {}
var dialog_index
var current_dialog_name

onready var dialog_container = get_node("dialog_menu/dialog_background/dialog_container")
onready var text_input = get_node("dialog_menu/MarginContainer/hbox/text_input")
onready var action_button = get_node("dialog_menu/MarginContainer/hbox/action_button")

onready var scene_to_open = null
onready var lock_thread = false
onready var next_action = ""

func _ready():
	GameManager.connect("start_dialog", self, "start_dialog")
	
	
func start_dialog(scene):
	current_dialog_name = scene
	dialog = StringManager.get_dialog(current_dialog_name)
	if dialog != null:
		dialog_index = 0
		get_parent().show_overlay()
		self.visible = true
		handle_dialog()
	else:
		kill_dialog()
		print("Error loading dialog " + current_dialog_name)

func kill_dialog():
	get_parent().hide_overlay()
	self.visible = false

func handle_dialog():
	var current_dialog_item = dialog[dialog_index]
	var state = current_dialog_item["state"]
	var text = current_dialog_item["text"]
	var animation = current_dialog_item["animation"] if !current_dialog_item["animation"].empty() else "default"
	var button_text = current_dialog_item["button_text"]
	next_action = current_dialog_item["next_action"]
	var duration = current_dialog_item["duration"]
	var text_speed = current_dialog_item["text_speed"] if TYPE_REAL == typeof(current_dialog_item["text_speed"]) else 0.03
	var sfx = current_dialog_item["sfx"]
	print("handling dialog------------------")
	print("current_dialog_item: " + String(dialog_index))
	print("state: " + String(state))
	print("text: " + String(text))
	print("animation: " + String(animation))
	print("button_text: " + String(button_text))
	print("next_action: " + String(next_action))
	print("duration: " + String(duration))
	print("text_speed: " + String(text_speed))
	print("sfx: " + String(sfx))
	print("---------------------------------")
	
	match state:
		"read":	
			text_input.visible = false
			showAnimation(animation)
			startDialog(text, text_speed, sfx)
			startButton(button_text)
		"input":
			showAnimation(animation)
			startInput()
			startButton(button_text)
		"read_input":
			showAnimation(animation)
			startDialog(text, text_speed, sfx)
			startInput()
			startButton(button_text)
		"cutscene":
			startCutScene(duration)
	
	
func showAnimation(animation):
	$dialog_menu/dialog_image/sprite_container/king.visible = false
	match animation:
		"goblin":
			$dialog_menu/dialog_image/sprite_container/king.visible = true
		"wizard":
			$dialog_menu/dialog_image/sprite_container/king.visible = true
		"king":
			$dialog_menu/dialog_image/sprite_container/king.visible = true


func startDialog(text, text_speed, sfx):
	var para = text if !text.empty() else ""
	if !sfx.empty():
		SystemManager.playSfx(sfx)
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
				SystemManager.data["name"] = text_input.text
				next_dialog()
		"close":
			kill_dialog()
 
func next_dialog():
	dialog_index += 1
	handle_dialog()