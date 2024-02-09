@tool
extends Node3D
@export_subgroup("Warp_properties")
@export var all_directions = false
@export var diagonal_entrance = true
@export var directions = Vector2i.ZERO
@export var warp_direction=0
@export_subgroup("Warp_to")
@export_file("*.tscn") var scene
@export var loading_preset = "nmp_noload"
@export var coordinate_and_direction = Vector4.ZERO
func _ready():
	if !Engine.is_editor_hint():
		if all_directions:
			var sphere = SphereShape3D.new()
			sphere.radius = 0.5
			$warp_area/warp.set_shape(sphere)

func _process(_delta):
	
	if Engine.is_editor_hint():
		$visual.visible=true
	else:
		$visual.visible=Global.debug
		
	if !all_directions:
		$visual.frame_coords.x=clamp(warp_direction,0,3)
	if all_directions:
		$visual.frame_coords.x=4
	
	if !all_directions:
		if warp_direction==0 || warp_direction==3:
			$warp_area/warp.get_shape().size = Vector3(2.,2.,0.)
		elif warp_direction==1 || warp_direction==2:
			$warp_area/warp.get_shape().size = Vector3(0.,2.,2.)
		
	
	warp_direction=clamp(warp_direction,0,3)

func _on_warp_area_body_entered(body):
	
	if body==get_tree().get_first_node_in_group("Player"):
		if diagonal_entrance:
			if get_tree().get_first_node_in_group("Player").animation_direction==directions.x || get_tree().get_first_node_in_group("Player").animation_direction==directions.y:
				Global.warp_to(scene,loading_preset)
				Global.player_array=coordinate_and_direction
		else:
			if get_tree().get_first_node_in_group("Player").animation_direction==warp_direction || all_directions:
				Global.warp_to(scene,loading_preset)
				Global.player_array=coordinate_and_direction
