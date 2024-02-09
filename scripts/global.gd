extends Node
#GLOBAL GAME VARS
var debug = true
#ROOM
var room_name ="test"
var loading_preset = ""
var fog_radius = 13.5
var fog_color = Vector4(0.0,0.0,0.0,0.0)

#CAMERA
var camera_mode = 0
var camera_limit_x = 2
var camera_limit_z = 2
var camera_limit_y = 4
var camera_rot = -18
var camera_dist_hor = 12
var camera_dist_ver = 4
var camera_move_x = true
var camera_move_z = true
var camera_move_y = true
var camera_root_dist_ver = 0.0
var cam_move_limit_x = Vector2.ZERO
var cam_move_limit_y = Vector2.ZERO
var cam_move_limit_z = Vector2.ZERO

#GAME
var control_mode = 0
var game_paused = false
var can_pause = true

#SAVEDATA
var gen = 6
var key = 0
var current_character = 0
var pieces_amount = [0,0]
# 0 = guardian
var player_array = Vector4(0.,0.,0.,0)
var pets = [false,false,false,false,false,false,false,false,false,false]
var fog_focus = 0
#0 = follow player
#


#GENERAL GAME MANAGEMENT
var directory = DirAccess.open("user://")
var fullscreen = false
var sheets = DirAccess.open("user://sheets")

#P2TALKDICT
var p2talkdict = {}

#DIALOGUE
var dialogue = {}

#LEVEL LOADING DATA
var level_data = {}

#PIECE_ARRAY
var pieces = [0,1,2,3,4,
			4,0,2,1,3,
			4,2,3,1,0,
			2,3,1,4,0,
			1,4,3,0,2,
			1,0,3,2,4,
			2,3,1,0,4,
			2,1,0,3,4,
			3,1,0,4,2,
			1,0,4,2,3]
#0 = CONE
#1 = TORUS
#2 = GREEN "SPHERE"
#3 = TRIANGLE
#4 = PINK PIECE

func _ready():
	#GAME BOOTUP
	#CHECKS IF CUSTOM SHEETS DIRECTORY DOESNT EXIST SO IT CAN CREATE IT
	if !directory.dir_exists("sheets"):
		directory.make_dir("sheets")
	if !directory.dir_exists("savedata"):
		directory.make_dir("savedata")
	#LOADS P2TOTALK DICTIONARY
	p2talkdict = JSON.parse_string((FileAccess.open("res://scripts/p2_talk_data.json", FileAccess.READ)).get_as_text())
	dialogue = JSON.parse_string((FileAccess.open("res://scripts/dialogue.json", FileAccess.READ)).get_as_text())
	level_data = JSON.parse_string((FileAccess.open("res://scripts/level_data.json", FileAccess.READ)).get_as_text())
	#SceneManager.change_scene("res://scenes/test.tscn")

func _process(_delta):
	if Input.is_action_just_pressed("screenshot"):
		var viewport_feed: Viewport =  get_tree().root.get_viewport()
		var screen_texture: Texture2D = viewport_feed.get_texture()
		var screen_image: Image = screen_texture.get_image()
		var screen: Texture2D = ImageTexture.create_from_image(screen_image)
		screen_image.save_png("user://sheets/screen.png")
	#CHECKS INPUTS FOR SHEET FOLDER HOTKEY AND FULLSCREEN BUTTON
	if Input.is_action_just_pressed("open_sheet_folder"):
		OS.shell_show_in_file_manager(ProjectSettings.globalize_path("user://sheets"),true)
		
	if Input.is_action_just_pressed("ui_end"):
		save_game(0)
	if Input.is_action_just_pressed("fullscreen"):
		fullscreen = !fullscreen
		DisplayServer.window_set_mode((DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED))


#FUNCTION THAT CHECKS P2TOTALK DICTIONARY TABLE, CALLED EVERY TIME P2TOTALK IS USED
func get_p2_word(word):
	if p2talkdict.find_key(word)!=null:
		return str(p2talkdict.find_key(word)).to_lower().capitalize()
	else:
		return "Not in Table"
		
func create_textbox(background,text):
	var textbox_scene = preload("res://scenes/objects/setup/player/textbox_object.tscn")
	var dialogue_instance = textbox_scene.instantiate()
	dialogue_instance.background = background
	dialogue_instance.text = text
	if get_tree().get_first_node_in_group("HUD_textboxes").get_child_count()<2:
		get_tree().get_first_node_in_group("HUD_textboxes").get_child(0).add_child(dialogue_instance)

func warp_to(scene,preset):
	can_pause=false
	#print(level_data)
	get_tree().get_first_node_in_group("loading_overlay").get_child(0).color=Color(level_data[preset]["fade_color"][0],level_data[preset]["fade_color"][1],level_data[preset]["fade_color"][2],0.)
	var fade_in = create_tween()
	fade_in.tween_property(get_tree().get_first_node_in_group("loading_overlay").get_child(0),"color:a",1.0,0.5)
	await fade_in.finished
	get_tree().paused=true
	if level_data[preset]["loading_file"]!=null:
		bg_music.stop()
		get_tree().get_first_node_in_group("loading_overlay").get_child(1).set_texture(load("res://graphics/sprites/ui/loading_screen/"+level_data[preset]["loading_file"]+".png"))
	get_tree().get_first_node_in_group("loading_overlay").get_child(2).wait_time =float(level_data[preset]["wait_time"])+randf_range(0.,float(level_data[preset]["wait_time"])/4)
	get_tree().get_first_node_in_group("loading_overlay").get_child(2).start()
	await get_tree().get_first_node_in_group("loading_overlay").get_child(2).timeout
	get_tree().change_scene_to_file(scene)
	
func save_data():
	var save_data = {
		"room": {
			"room_name":room_name,
			"loading_preset":loading_preset,
			"current_room": get_tree().get_current_scene().scene_file_path
		},
		"game": {
			"gen": gen,
			"pets": pets
		},
		"player": {
			"coords":[get_tree().get_first_node_in_group("Player").position.x,get_tree().get_first_node_in_group("Player").position.y,get_tree().get_first_node_in_group("Player").position.z,get_tree().get_first_node_in_group("Player").animation_direction],
			"pieces":pieces_amount,
			"character":current_character,
			"control_mode":control_mode,
			"key":key
		}
	}
	return save_data

func save_game(slot):
	var save_game = FileAccess.open("user://savedata/saveslot"+str(slot)+".save",FileAccess.WRITE)
	var json_data = JSON.stringify(save_data())
	save_game.store_line(json_data)
	
func load_game(slot):
	if not FileAccess.file_exists("user://savedata/saveslot"+str(slot)+".save"):
		return
	var save_game = JSON.parse_string((FileAccess.open("user://savedata/saveslot"+str(slot)+".save",FileAccess.READ)).get_as_text())
	gen = save_game["game"]["gen"]
	pets = save_game["game"]["pets"]
	player_array = Vector4(save_game["player"]["coords"][0],save_game["player"]["coords"][1],save_game["player"]["coords"][2],save_game["player"]["coords"][3])
	pieces_amount = save_game["player"]["pieces"]
	control_mode = save_game["player"]["control_mode"]
	key = save_game["player"]["key"]
	warp_to(save_game["room"]["current_room"],"evencare")
