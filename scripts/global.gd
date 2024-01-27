extends Node

#ROOM
var room_name ="test"
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
var fog_radius = 13.5
var fog_color = Vector4(0.0,0.0,0.0,0.0)

#GAME
var control_mode = 0
var current_character = 0
# 0 = guardian
var fog_focus = 0
#0 = player
#

#MANAGEMENT
var directory = DirAccess.open("user://")
var widescreen = false
var fullscreen = false
var upscale = false
var sheets = DirAccess.open("user://sheets")
var p2talkdict = {}

func _ready():
	if !directory.dir_exists("sheets"):
		directory.make_dir("sheets")
	p2talkdict = JSON.parse_string((FileAccess.open("res://scripts/p2_talk_data.json", FileAccess.READ)).get_as_text())
	# SceneManager.change_scene("res://scenes/test.tscn")
func adjust_resolution():
	if widescreen:
		if fullscreen:
			get_viewport().content_scale_size = Vector2((DisplayServer.screen_get_size()).x/1.5,720)
		else:
			get_viewport().content_scale_size = Vector2(((DisplayServer.screen_get_size()).x+120)/1.5,720)
func _process(_delta):
	if Input.is_action_just_pressed("open_sheet_folder"):
		OS.shell_show_in_file_manager(ProjectSettings.globalize_path("user://sheets"),true)
	if Input.is_action_just_pressed("fullscreen"):
		fullscreen = !fullscreen
		adjust_resolution()
		DisplayServer.window_set_mode((DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED))
	RenderingServer.global_shader_parameter_set("fog_color", fog_color)
	RenderingServer.global_shader_parameter_set("sphere_size", fog_radius)
			
func get_p2_word(word):
	if p2talkdict.find_key(word)!=null:
		return str(p2talkdict.find_key(word)).to_lower().capitalize()
	else:
		return "Not in Table"
		
