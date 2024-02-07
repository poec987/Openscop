extends Node
@export_subgroup("Level Settings")
@export var background_music: Resource
@export var loading_screen: Resource
@export_subgroup("Limit Camera")
@export var limit_camera = false
@export var horizontal_limit = Vector2.ZERO
@export var front_limit = Vector2.ZERO
@export var vertical_limit = Vector2.ZERO
@export_subgroup("Camera_properties")
@export var allow_horizontal_movement = true
@export var allow_front_movement = true
@export var allow_vertical_movement = true
@export var camera_height = 0.
@export var camera_distance = 0.
@export_subgroup("Max distance from guardian")
@export var horizontal_max_limit = 0.
@export var front_max_limit = 0.
@export var vertical_max_limit = 0.
@export_subgroup("Fog Color")
@export var color = Vector4.ZERO
@export_subgroup("Fog Size")
@export var fog_radius = 0.
@export_subgroup("Hardcoded Preset")
@export var preset = 0
#0 = EVENCARE/GIFTPLANE
#1 = NMP
@onready var player_camera = get_tree().get_first_node_in_group("Player_camera")
#func _ready():
	#if Global.camera_dist_ver!=camera_height || camera_height>0.:
		#Global.camera_dist_ver = camera_height
	#if Global.camera_dist_hor!=camera_distance || camera_distance>0.:
		#Global.camera_dist_hor = camera_distance
	#if Global.camera_move_x!=allow_horizontal_movement:
		#Global.camera_move_x=allow_horizontal_movement
	#if Global.camera_move_y!=allow_vertical_movement:
		#Global.camera_move_y=allow_vertical_movement
	#if Global.camera_move_z!=allow_front_movement:
		#Global.camera_move_z=allow_front_movement
	#if Global.camera_limit_x!=horizontal_max_limit && horizontal_max_limit>0.:
		#Global.camera_limit_x=horizontal_max_limit
	#if Global.camera_limit_y!=vertical_max_limit && vertical_max_limit>0.:
		#Global.camera_limit_y=vertical_max_limit
	#if Global.camera_limit_z!=front_max_limit && front_max_limit>0.:
		#Global.camera_limit_z=front_max_limit
		
func _process(_delta):
	if horizontal_limit!=Vector2.ZERO:
		player_camera.position.x = clamp(player_camera.position.x,horizontal_limit.x,horizontal_limit.y)
	if vertical_limit!=Vector2.ZERO:
		player_camera.position.y = clamp(player_camera.position.y,vertical_limit.x,vertical_limit.y)
	if front_limit!=Vector2.ZERO:
		player_camera.position.z = clamp(player_camera.position.z,front_limit.x,front_limit.y)
