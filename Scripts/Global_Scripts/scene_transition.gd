extends Node

signal loading_scene()
signal loading_progress()

var scene_list = {}
var loadingThread: Thread

# Called when the node enters the scene tree for the first time.
func _ready():
	scene_list["menu"] = "main_menu"
	scene_list["tutorial"] = "tutorial"
	scene_list["game"] = "Game"

func change_scene(scene):
	get_tree().change_scene("res://Scenes/" + scene_list[scene] + ".tscn")

# Loads the scene with the given name and also forgets to unload the previous one
func background_load_scene(path):
	loadingThread  = Thread.new()
	loadingThread.start(self, "background_load", scene_list[path]) #Starts loading the new scene on the loading thread

func background_load(path):
	var loader = ResourceLoader.load_interactive("res://Scenes/" + path + ".tscn") #Loads the scene with the given path
	var stageCount = loader.get_stage_count() #Total number of items to load before loading is finished
	emit_signal("loading_scene", stageCount) #Update loading screen
	
	var gameScene = null
	var loading = true
	
	while(loading): #Repeat loading is done
		#print('loading...')
		# Update the loading screen on the progress
		emit_signal("loading_progress",loader.get_stage())
		#print(loader.get_stage())
		# Delay for 0.01 second
		OS.delay_msec(10.0)
		
		#Loads the next step
		var error = loader.poll()
		
		if (error == ERR_FILE_EOF): #End of file indicates the loading has completed
			gameScene = loader.get_resource()
			loading = false
		elif (error != OK): #Other error happened
			emit_signal("failed_to_load_scene")
			loading = false
	
	if gameScene != null:
		#print('done')
		call_deferred("background_load_done", gameScene)

func background_load_done(scene):
	loadingThread.wait_to_finish()
	# Instantiate new scene
	var sceneInstance = scene.instance()
	
	#Free the current scene and replace it with the new game scene
	get_tree().current_scene.free()
	get_tree().current_scene = null
	get_tree().root.add_child(sceneInstance) 
	get_tree().current_scene = sceneInstance