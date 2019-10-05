extends Control

signal build(val)

var build = false
var s1 = preload("res://Assets/Music/ambient.wav")
var s2 = preload("res://Assets/Music/main_theme.wav")

func _ready():
	ResourceManager.connect("update_resource", self, "update_resource")
	$options_menu.hide()
	yield(get_tree().create_timer(randi()%20 + 4), "timeout")
	$AudioStreamPlayer2D.play()


func update_resource(resource, value):
	if resource != null:
		var value_to_update
		match resource:
			ResourceManager.Resource.WOOD:
				value_to_update = $VBoxContainer/bottom_menu/bottom_menu_list/resources/Tree/wood/value
			ResourceManager.Resource.STONE:
				value_to_update = $VBoxContainer/bottom_menu/bottom_menu_list/resources/Tree2/stone/value
			ResourceManager.Resource.GOLD:
				value_to_update = $VBoxContainer/bottom_menu/bottom_menu_list/resources/Tree3/gold/value
			ResourceManager.Resource.FOOD:
				value_to_update = $VBoxContainer/bottom_menu/bottom_menu_list/resources/Tree4/food/value
			ResourceManager.Resource.POPULATION:
				value_to_update = $VBoxContainer/bottom_menu/bottom_menu_list/resources/Tree5/population/value
			ResourceManager.Resource.EGG:
				value_to_update = $VBoxContainer/bottom_menu/bottom_menu_list/resources/Tree6/eggs/value
		if value_to_update != null:
			value_to_update.text = String(int(value_to_update.text) + value)
			#TODO ANIMATION!

func _on_settings_button_pressed():
	if $options_menu.is_visible_in_tree():
		$options_menu.hide()
	else:
		$options_menu.show()


func _on_resume_button_pressed():
	$options_menu.hide()


func _on_quit_button_pressed():
	scene_transition.change_scene("menu")

func _on_build_button_pressed():
	build = not build
	if build:
		$VBoxContainer/build_button.modulate = Color(0.4,0.4,0.4,1.0)
	else:
		$VBoxContainer/build_button.modulate = Color(1.0,1.0,1.0,1.0)
	emit_signal("build", build)


func _on_AudioStreamPlayer2D_finished():
	randomize()
	yield(get_tree().create_timer(randi()%20 + 4), "timeout")
	if $AudioStreamPlayer2D.stream == s2:
		 $AudioStreamPlayer2D.stream = s1
	else:
		$AudioStreamPlayer2D.stream = s2
	$AudioStreamPlayer2D.play()
