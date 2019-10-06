extends Control

signal build(type, val)

var build = false
var s1 = preload("res://Assets/Music/ambient.wav")
var s2 = preload("res://Assets/Music/main_theme.wav")
var current = null

onready var clock = get_node("clock")
onready var attractive_meter = get_node("attractive_meter")
func _ready():
	reset_build_buttons()
	init_resources()
	ResourceManager.connect("update_resource", self, "update_resource")
	GameManager.connect("gameplay_tick", self, "gameplay_tick")
	GameManager.connect("update_attractiveness", self, "update_attractiveness")
	
	$options_menu.hide()
	yield(get_tree().create_timer(randi()%20 + 4), "timeout")
	$AudioStreamPlayer2D.play()

func init_resources():
	update_resource(ResourceManager.Resource.WOOD)
	update_resource(ResourceManager.Resource.STONE)
	update_resource(ResourceManager.Resource.GOLD)
	update_resource(ResourceManager.Resource.FOOD) 
	update_resource(ResourceManager.Resource.POPULATION)
	update_resource(ResourceManager.Resource.MAX_POPULATION)
	update_resource(ResourceManager.Resource.EGG)


func update_resource(resource):
	if resource != null:
		var value_to_update
		match resource:
			ResourceManager.Resource.WOOD:
				$VBoxContainer/bottom_menu/bottom_menu_list/resources/Tree/wood/value.text = String(ResourceManager.get_value(ResourceManager.Resource.WOOD))
			ResourceManager.Resource.STONE:
				$VBoxContainer/bottom_menu/bottom_menu_list/resources/Tree2/stone/value.text = String(ResourceManager.get_value(ResourceManager.Resource.STONE))
			ResourceManager.Resource.GOLD:
				$VBoxContainer/bottom_menu/bottom_menu_list/resources/Tree3/gold/value.text = String(ResourceManager.get_value(ResourceManager.Resource.GOLD))
			ResourceManager.Resource.FOOD:
				$VBoxContainer/bottom_menu/bottom_menu_list/resources/Tree4/food/value.text = String(ResourceManager.get_value(ResourceManager.Resource.FOOD))
			ResourceManager.Resource.POPULATION:
				$VBoxContainer/bottom_menu/bottom_menu_list/resources/Tree5/population/value.text =  String(ResourceManager.get_value(ResourceManager.Resource.POPULATION))
			ResourceManager.Resource.MAX_POPULATION:
				$VBoxContainer/bottom_menu/bottom_menu_list/resources/Tree5/population/max_value.text =  String(ResourceManager.get_value(ResourceManager.Resource.MAX_POPULATION))
			ResourceManager.Resource.EGG:
				 $VBoxContainer/bottom_menu/bottom_menu_list/resources/Tree6/eggs/value.text = String(ResourceManager.get_value(ResourceManager.Resource.EGG))


func _on_settings_button_pressed():
	if $options_menu.is_visible_in_tree():
		hide_menu()
	else:
		show_menu()

func _on_resume_button_pressed():
	hide_menu()


func _on_quit_button_pressed():
	SystemManager.save_player_data()
	scene_transition.change_scene("menu")

func no_build():
	build = false
	reset_build_buttons()

func _on_build_button_pressed():
	build = not build
	reset_build_buttons()
	if current != "blank":
		build = true
		current = "blank"
	if build:
		$VBoxContainer/Container/build_button.modulate = Color(1.0,1.0,1.0,1.0)
	
	emit_signal("build", "blank", build)


func _on_AudioStreamPlayer2D_finished():
	randomize()
	yield(get_tree().create_timer(randi()%20 + 4), "timeout")
	if $AudioStreamPlayer2D.stream == s2:
		 $AudioStreamPlayer2D.stream = s1
	else:
		$AudioStreamPlayer2D.stream = s2
	$AudioStreamPlayer2D.play()


func reset_build_buttons():
	for item in $VBoxContainer/Container.get_children():
		if item.name != "details":
			item.modulate = Color(0.4,0.4,0.4,1.0)	
		

func _on_hut_button_pressed():
	build = not build
	reset_build_buttons()
	if current != "hut":
		build = true
		current = "hut"
	if build:
		$VBoxContainer/Container/hut_button.modulate = Color(1.0,1.0,1.0,1.0)
	emit_signal("build", "hut", build)

func gameplay_tick():
	var rotation
	if GameManager.is_daytime():
		rotation = 180/GameManager.DAY_LENGTH
	else:
		rotation = 180/GameManager.NIGHT_LENGTH
	clock.rect_rotation -= rotation

func update_attractiveness():
	attractive_meter

func show_menu():
	if !$dialog_screen.visible:
		show_overlay()
	$options_menu.show()
	
func hide_menu():
	if !$dialog_screen.visible:
		hide_overlay()
	$options_menu.hide()
		
func show_overlay():
	$background_filter.show()
	
func hide_overlay():
	$background_filter.hide()

func show_goblin(details):
	$VBoxContainer/Container/details.show()
	$VBoxContainer/Container/details/MarginContainer/VBoxContainer/HBoxContainer/Tree/HBoxContainer/health_val.text = details[0]
	$VBoxContainer/Container/details/MarginContainer/VBoxContainer/HBoxContainer/Tree2/HBoxContainer/hunger_val.text = details[1]
	$VBoxContainer/Container/details/MarginContainer/VBoxContainer/HBoxContainer/Tree3/HBoxContainer/energy_val.text = details[2]
	$VBoxContainer/Container/details/MarginContainer/VBoxContainer/HBoxContainer/Tree4/HBoxContainer/happiness_val.text = details[3]
	$VBoxContainer/Container/details/MarginContainer/VBoxContainer/HBoxContainer/Tree5/HBoxContainer/strength_val.text = details[4]
	$VBoxContainer/Container/details/MarginContainer/VBoxContainer/HBoxContainer2/name.text = "name: " + details[5]
	$VBoxContainer/Container/details/MarginContainer/VBoxContainer/HBoxContainer2/job.text = "job: " + details[6]

func hide_goblin():
	$VBoxContainer/Container/details.hide()