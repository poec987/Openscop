extends Node 
# do you think its worth it to make this a class? - izz

@export_subgroup("Level Settings")
@export var room_name = ""
@export var loading_preset=""
@export var background_music_id = 0
@export var fade_color: Color
@export_multiline var level_slogan = ""
@export var school_preset = false 

@export_subgroup("Limit Camera")
@export var limit_camera_horizontal = false
@export var horizontal_limit = Vector2.ZERO
@export var limit_camera_front = false
@export var front_limit = Vector2.ZERO
@export var limit_camera_vertical = false
@export var vertical_limit = Vector2.ZERO

@export_subgroup("Camera_properties")
@export var allow_horizontal_movement = true
@export var allow_front_movement = true
@export var allow_vertical_movement = true
@export var camera_height = 0.
@export var camera_distance = 0.
@export var change_camera_angle = false
@export var camera_angle = 0.
@export var camera_root_offset_y = 0.

@export_subgroup("Max distance from guardian")
@export var horizontal_max_limit = 0.
@export var front_max_limit = 0.
@export var vertical_max_limit = 0.

@export_subgroup("Environment")
@export var enable_fog = false
@export var texture_background = false
@export var texture: Texture2D
@export var scroll_speed = 0.25
@export var sky_and_fog_color = Vector4.ZERO
@export var fog_radius = 0.
@export var ambient_color = Color(0., 0., 0.,1.0)
@export var environment_darkness = 0.
@export var set_custom_fog_focus = false
@export var set_fog_focus = Vector3.ZERO

@export_subgroup("Hardcoded Preset")
@export var preset = 0
# 1 = EVENCARE/GIFTPLANE
# 2 = NMP

func _ready():
	Global.room_name = room_name
	Global.loading_preset = loading_preset
	get_tree().paused=false
	get_tree().get_first_node_in_group("level_slogan").text = level_slogan
	get_tree().get_first_node_in_group("loading_overlay").get_child(0).color=fade_color
	if Global.camera_dist_ver!=camera_height || camera_height>0.:
		Global.camera_dist_ver = camera_height
	if Global.camera_dist_hor!=camera_distance || camera_distance>0.:
		Global.camera_dist_hor = camera_distance
	if Global.camera_move_x!=allow_horizontal_movement:
		Global.camera_move_x=allow_horizontal_movement
	if Global.camera_move_y!=allow_vertical_movement:
		Global.camera_move_y=allow_vertical_movement
	if Global.camera_move_z!=allow_front_movement:
		Global.camera_move_z=allow_front_movement
	if Global.camera_limit_x!=horizontal_max_limit && horizontal_max_limit>0.:
		Global.camera_limit_x=horizontal_max_limit
	if Global.camera_limit_y!=vertical_max_limit && vertical_max_limit>0.:
		Global.camera_limit_y=vertical_max_limit
	if Global.camera_limit_z!=front_max_limit && front_max_limit>0.:
		Global.camera_limit_z=front_max_limit
	
	if limit_camera_horizontal:
		Global.cam_move_limit_x.x=horizontal_limit.x
		Global.cam_move_limit_x.y=horizontal_limit.y
	else:
		Global.cam_move_limit_x=Vector2.ZERO
	
	if limit_camera_front:
		Global.cam_move_limit_z.x=front_limit.x
		Global.cam_move_limit_z.y=front_limit.y
	else:
		Global.cam_move_limit_z=Vector2.ZERO
	
	if limit_camera_vertical:
		Global.cam_move_limit_y.x=vertical_limit.x
		Global.cam_move_limit_y.y=vertical_limit.y
	else:
		Global.cam_move_limit_y=Vector2.ZERO
	
	if camera_height!=0.0:
		Global.camera_dist_ver=camera_height
	else:
		Global.camera_dist_ver=4
		
	if camera_distance!=0.0:
		Global.camera_dist_hor=camera_distance
	else:
		Global.camera_dist_hor=12
	
	if camera_root_offset_y!=0.0:
		Global.camera_root_dist_verhor=camera_root_offset_y
		
	if change_camera_angle:
		Global.camera_rot = camera_angle
	else:
		Global.camera_rot = -18
		
	if school_preset:
		Global.control_mode=4
		
	if set_custom_fog_focus:
		Global.fog_focus=-1
		RenderingServer.global_shader_parameter_set("player_pos", set_fog_focus)
	
	
	if ambient_color!=Color(0., 0., 0.,1.0):
		$skybox.get_environment().set_ambient_light_color(ambient_color)
	else:
		$skybox.get_environment().set_ambient_light_color(Color(0.89, 0.89, 0.89,1.0))
	
	if environment_darkness!=0.:
		$skybox.get_environment().ambient_light_energy = environment_darkness
	else:
		$skybox.get_environment().ambient_light_energy = 0.73
	
	if enable_fog:
		RenderingServer.global_shader_parameter_set("fog_enable", true)
		if sky_and_fog_color!=Vector4(0.,0.,0.,0.):
		#SETS FOG COLOR AND FOG RADIUS AS GAME RUNS
			RenderingServer.global_shader_parameter_set("fog_color", sky_and_fog_color)
			$skybox.get_environment().set_bg_color(Color(sky_and_fog_color.x,sky_and_fog_color.y,sky_and_fog_color.z,sky_and_fog_color.w))
		else:
			RenderingServer.global_shader_parameter_set("fog_color", Vector4.ZERO)
			$skybox.get_environment().set_bg_color(Color(0.,0.,0.,0.))
			if fog_radius!=0.:
				RenderingServer.global_shader_parameter_set("sphere_size", fog_radius)
			else:
				RenderingServer.global_shader_parameter_set("sphere_size", 13.5)
	else:
		RenderingServer.global_shader_parameter_set("fog_enable", false)
	
	if !texture_background:
		$background/color.visible=true
		$background/texture.visible=false
		$background/color.color = Color(sky_and_fog_color.x,sky_and_fog_color.y,sky_and_fog_color.z,1.0)
	else:
		$background/color.visible=false
		$background/texture.visible=true
		if texture!=null:
			$background/texture.texture=texture
		$background/texture.get_material().set_shader_parameter("scroll_speed",scroll_speed)
	bg_music.play_track(background_music_id)
	
