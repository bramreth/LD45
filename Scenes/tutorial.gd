extends Control

var text_queue = ["you are one of the last goblins left, hunted to near extinction by the nasty human king Clement",
	"you have nothing left, is this the end for you?"]
var text_queue_2 = ["A goblin! what a rarity. Greetings, I am Higgledy Piggledy the Wiggley merchant wizard at your service!",
	"If you are going to survive the wrath of nasty king Clement you'll need all the help you can get.", 
	"If you build a camp here you will attract local straggler goblins to join you!",
	 "The more ATTRACTIVE your home the more wild goblins will be drawn to join you in your efforts to survive."]
var name_msg = "you need to choose a name little goblin."
var para = ""
var text_speed = 0.03 # lower is faster
var current_scene
var lock_thread = false

var player_name = ""

var scene_queue = ["text", "name_prompt", "cutscene", "text", "end"]
# this is the tutorial script, we want to write text in a specifiv order
func _ready():
	next_scene()

func confirm_dialog():
	if lock_thread:
		return
	if not text_queue.empty():
		para = text_queue.pop_front()
		$MarginContainer/VBoxContainer/RichTextLabel.text = ""
		while para != "":
			lock_thread = true
			yield(get_tree().create_timer(text_speed), "timeout")
			$MarginContainer/VBoxContainer/RichTextLabel.text += para.left(1)
			para = para.right(1)
		lock_thread = false
	else:
		next_scene()
		
func name_prompt():
	if lock_thread:
		return
	if not $MarginContainer/VBoxContainer/LineEdit.text.empty():
		player_name = $MarginContainer/VBoxContainer/LineEdit.text
		next_scene()
	else:
		$MarginContainer/VBoxContainer/RichTextLabel.text = ""
		var txt = name_msg
		while txt != "":
			lock_thread = true
			yield(get_tree().create_timer(text_speed), "timeout")
			$MarginContainer/VBoxContainer/RichTextLabel.text += txt.left(1)
			txt = txt.right(1)
		lock_thread = false
		

func _on_Button_pressed():
	handle_scene()
	
func next_scene():
	if not scene_queue.empty():
		current_scene = scene_queue.pop_front()
		handle_scene()
	else:
		#end the tutorial
		pass

func handle_scene():
	print(current_scene)
	match current_scene:
		"text":
			$MarginContainer/VBoxContainer/Button.visible = true
			$MarginContainer/VBoxContainer/LineEdit.visible = false
			confirm_dialog()
		"name_prompt":
			$MarginContainer/VBoxContainer/LineEdit.visible = true
			name_prompt()
		"cutscene":
			$MarginContainer/VBoxContainer/Button.visible = true
			$MarginContainer/VBoxContainer/LineEdit.visible = false
			print("show the cave, the mercant wizard appears")
			text_queue = text_queue_2
			next_scene()
		"end":
			scene_transition.change_scene("game")
	
	
	
	

func _on_LineEdit_text_entered(new_text):
	if not new_text.empty():
		player_name = new_text
		handle_scene()
