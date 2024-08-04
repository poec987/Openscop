@tool
extends Node3D

@export_category("Properties")
@export var instant = false
@export var use_default_smooth = true
@export var smoothness = 1.0
@export var instant_out = false
@export var use_default_smooth_out = true
@export var smoothness_out = 2.5


@onready var player = get_tree().get_first_node_in_group("Player")

@onready var target_position = Vector3.ZERO 
var inside = false
func _ready():
	target_position = get_child(1).global_position

func _process(delta):
	$zone_area/zone_collision.get_shape().size= scale
	$zone_area/zone_collision/zone_mesh.scale = scale
	$zone_area/zone_collision.get_shape().size = scale
	
	if !Engine.is_editor_hint():
		get_tree().get_first_node_in_group("Player_camera").pos_argument = get_tree().get_first_node_in_group("Player_camera").global_position
		visible = Global.debug
		if inside:
			if use_default_smooth:
				smoothness = 1.0
			if !instant:
				get_tree().get_first_node_in_group("Player_camera").pos_argument = get_tree().get_first_node_in_group("Player_camera").global_position.lerp(target_position, smoothness*delta)
			else:
				get_tree().get_first_node_in_group("Player_camera").pos_argument = target_position
		else:
			if use_default_smooth_out:
				smoothness = 1.0
			if !instant:
				get_tree().get_first_node_in_group("Player_camera").pos_argument = get_tree().get_first_node_in_group("Player_camera").pos_argument.lerp(get_tree().get_first_node_in_group("Player").global_position, smoothness*delta)
			else:
				get_tree().get_first_node_in_group("Player_camera").pos_argument = target_position
				
func _on_zone_area_body_entered(body):
	if body==get_tree().get_first_node_in_group("Player"):
		inside = true
		Global.camera_mode = 1
func _on_zone_area_body_exited(body):
	if body==get_tree().get_first_node_in_group("Player"):
		inside = false
