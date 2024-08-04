@tool
extends Node3D

@export_category("Properties")
@export var place_camera = false
@export var rotate_camera = false
@export var instant = false
@export var use_default_smooth = true
@export var smoothness = 1.0
@export var instant_out = false
@export var use_default_smooth_out = true
@export var smoothness_out = 2.5


@onready var player = get_tree().get_first_node_in_group("Player")

var inside = false
func _process(delta):
	$zone_area/zone_collision.get_shape().size= scale
	$zone_area/zone_collision/zone_mesh.scale = scale
	$zone_area/zone_collision.get_shape().size = scale
	if !Engine.is_editor_hint():
		visible = Global.debug
		if inside:
			if place_camera:
				if use_default_smooth:
					smoothness = 1.0
				if !instant:
					get_tree().get_first_node_in_group("Player_camera").pos_argument = get_tree().get_first_node_in_group("Player_camera").pos_argument.lerp(get_child(1).global_position, smoothness*delta)
					if rotate_camera:
						get_tree().get_first_node_in_group("Player_camera").rot_argument = get_tree().get_first_node_in_group("Player_camera").rot_argument.lerp(get_child(1).global_rotation, smoothness*delta)
					else:
						get_tree().get_first_node_in_group("Player_camera").rot_argument = null
				else:
					get_tree().get_first_node_in_group("Player_camera").pos_argument = get_child(1).global_position
					if rotate_camera:
						get_tree().get_first_node_in_group("Player_camera").rot_argument = get_child(1).global_rotation
					else:
						get_tree().get_first_node_in_group("Player_camera").rot_argument = null
	else:
		if place_camera && get_child_count()<2:
			print("ADD NODE AS A CHILD TO THIS OBJECT FIRST!!")
			place_camera = false
		else:
			if get_node_or_null("Camera3D"):
				get_child(1).fov = 35.0

func _on_zone_area_body_entered(body):
	if body==get_tree().get_first_node_in_group("Player"):
		inside = true
		if place_camera:
			get_tree().get_first_node_in_group("Player_camera").pos_argument = get_tree().get_first_node_in_group("Player_camera").get_child(0).global_position
			if rotate_camera:
				get_tree().get_first_node_in_group("Player_camera").rot_argument = get_tree().get_first_node_in_group("Player_camera").get_child(0).global_rotation
			Global.camera_mode = 1
func _on_zone_area_body_exited(body):
	if body==get_tree().get_first_node_in_group("Player"):
		inside = false
		
		#TO BE FIXED
		if use_default_smooth_out:
			smoothness_out = 5.5
		
		get_tree().get_first_node_in_group("Player_camera").smooth_out = smoothness_out
		
		if instant_out:	
			get_tree().get_first_node_in_group("Player_camera").smooth_out = -1.0
		
		if place_camera:
			Global.camera_mode = 0
