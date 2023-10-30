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

#GAME
var control_mode = 0
var current_character = "guardian"

#MANAGEMENT
var directory = DirAccess.open("user://")
var sheets = DirAccess.open("user://sheets")


func _ready():
	if !directory.dir_exists("sheets"):
		directory.make_dir("sheets")
	SceneManager.change_scene("res://scenes/test.tscn")

func _process(delta):
	if Input.is_action_just_pressed("open_sheet_folder"):
		OS.shell_show_in_file_manager(ProjectSettings.globalize_path("user://sheets"),true)
