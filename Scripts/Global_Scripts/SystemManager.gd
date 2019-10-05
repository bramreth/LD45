extends Node

onready var musicPlayer = AudioStreamPlayer2D.new()
onready var sfxPlayer = AudioStreamPlayer2D.new()
const sfx_dir = "res://Assets/SFX/"
const bgm_dir = "res://Assets/Music/"

var playerData = JSON
var playerDataPath = "res://GameData/player_data.json"
func _ready():
	load_Player_data()	
	
func load_Player_data():
	var file = File.new()
	file.open(playerDataPath, file.READ)
	playerData = JSON.parse(file.get_as_text()).result
	file.close()

func save_player_data():
	var settingsFile = File.new()
	settingsFile.open(playerDataPath, settingsFile.WRITE)
	settingsFile.store_line(to_json(playerData))
	settingsFile.close()
		
func changeBackgroundMusic(track):	
	musicPlayer.stream = load(bgm_dir + track)
	musicPlayer.play()

func playSfx(track):
	sfxPlayer.stream = load(sfx_dir + track)
	sfxPlayer.play()