extends Control

signal build(type, val)

var build = false
var s1 = preload("res://Assets/Music/ambient.wav")
var s2 = preload("res://Assets/Music/main_theme.wav")
var current = null
var music_swap = true

onready var clock = get_node("clock")
onready var attractive_meter = get_node("attractive_meter")

onready var resource_arrows = get_node("arrows")
onready var attract_arrow = get_node("arrows2")
onready var food_arrow = get_node("arrows3")
onready var population_arrow = get_node("arrows4")
onready var eggs_arrow = get_node("arrows5")
onready var time_arrow = get_node("arrows6")
onready var building_arrows = get_node("arrows7")
func _ready():
	$attractiveness_meter.value = GameManager.get_attractiveness()
	reset_build_buttons()
	init_resources()
	ResourceManager.connect("update_resource", self, "update_resource")
	GameManager.connect("gameplay_tick", self, "gameplay_tick")
	GameManager.connect("update_moral_image", self, "update_moral")
	
	$options_menu.hide()
	play_music()

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


func play_music():
	randomize()
	if music_swap:
		 SystemManager.changeBackgroundMusic("main_theme.wav")
	else:
		SystemManager.changeBackgroundMusic("ambient.wav")
	music_swap = not music_swap
	yield(get_tree().create_timer(randi()%60 + 60), "timeout")
	play_music()


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
	emit_signal("build", GameManager.Building.HUT, build)

func gameplay_tick():
	var rotation
	var tween = $clock/Tween
	if GameManager.is_daytime():
		rotation = 180/GameManager.DAY_LENGTH
	else:
		rotation = 180/GameManager.NIGHT_LENGTH
	tween.interpolate_property(clock, "rect_rotation", clock.rect_rotation, clock.rect_rotation - rotation, 1.0, Tween.TRANS_LINEAR,Tween.EASE_IN)
	tween.interpolate_property($attractiveness_meter, "value", $attractiveness_meter.value, (GameManager.get_attractiveness() / 3) + (GameManager.get_happiness()/3) + (33 * (1 - (ResourceManager.get_value(ResourceManager.Resource.POPULATION) / ResourceManager.get_value(ResourceManager.Resource.MAX_POPULATION)))), 0.2, Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.start()
	
	 
#	clock.rect_rotation -= rotation

func update_moral(state):
	match state:
		GameManager.Moral.PURE:
			pass
		GameManager.Moral.GOOD:
			pass
		GameManager.Moral.NICE:
			pass
		GameManager.Moral.MEAN:
			pass
		GameManager.Moral.BAD:
			pass
		GameManager.Moral.EVIL:
			pass
	
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

func _on_camp_button_pressed():
	build = not build
	reset_build_buttons()
	if current != "camp":
		build = true
		current = "camp"
	if build:
		$VBoxContainer/Container/camp_button.modulate = Color(1.0,1.0,1.0,1.0)
	
	emit_signal("build", GameManager.Building.CAMP, build)


func _on_mess_button_pressed():
	build = not build
	reset_build_buttons()
	if current != "mess":
		build = true
		current = "mess"
	if build:
		$VBoxContainer/Container/mess_button.modulate = Color(1.0,1.0,1.0,1.0)
	
	emit_signal("build", GameManager.Building.MESS, build)


func _on_hatch_button_pressed():
	build = not build
	reset_build_buttons()
	if current != "hatch":
		build = true
		current = "hatch"
	if build:
		$VBoxContainer/Container/hatch_button.modulate = Color(1.0,1.0,1.0,1.0)
	
	emit_signal("build", GameManager.Building.HATCHERY, build)
	

