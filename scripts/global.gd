extends Node
#GLOBAL GAME VARS

#ROOM
var room_name ="test"
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

#GAME
var control_mode = 0
var game_paused = false

#SAVEDATA
var current_character = 0
var pieces_amount = [0,0]
# 0 = guardian
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
	#LOADS P2TOTALK DICTIONARY
	p2talkdict = JSON.parse_string((FileAccess.open("res://scripts/p2_talk_data.json", FileAccess.READ)).get_as_text())
	dialogue = JSON.parse_string((FileAccess.open("res://scripts/dialogue.json", FileAccess.READ)).get_as_text())
	
	#SceneManager.change_scene("res://scenes/test.tscn")

func _process(_delta):
	if Input.is_action_just_pressed("pressed_start") && Global.control_mode==0:
		Global.game_paused=!Global.game_paused
	#CHECKS INPUTS FOR SHEET FOLDER HOTKEY AND FULLSCREEN BUTTON
	if Input.is_action_just_pressed("open_sheet_folder"):
		OS.shell_show_in_file_manager(ProjectSettings.globalize_path("user://sheets"),true)
	if Input.is_action_just_pressed("fullscreen"):
		fullscreen = !fullscreen
		DisplayServer.window_set_mode((DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED))
	
	#SETS FOG COLOR AND FOG RADIUS AS GAME RUNS
	RenderingServer.global_shader_parameter_set("fog_color", fog_color)
	RenderingServer.global_shader_parameter_set("sphere_size", fog_radius)

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
