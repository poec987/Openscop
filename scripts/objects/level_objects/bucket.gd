extends CharacterBody3D
#MAKING HISTORY
var v = 0
var h = 0
var delta_time = 0
const ACCELERATION = 16

func _physics_process(delta):
	#v = int($raycast/z_positive.is_colliding() && $raycast/z_positive.get_collider(0)==get_tree().get_first_node_in_group("Player"))*-1 + int($raycast/z_negative.is_colliding() && $raycast/z_negative.get_collider(0)==get_tree().get_first_node_in_group("Player"))
	#h = int($raycast/x_positive.is_colliding() && $raycast/x_positive.get_collider(0)==get_tree().get_first_node_in_group("Player"))*-1 + int($raycast/x_negative.is_colliding() && $raycast/x_negative.get_collider(0)==get_tree().get_first_node_in_group("Player"))
	#velocity.z = lerp(velocity.z,v*float(get_tree().get_first_node_in_group("Player").movement_speed),(delta)*ACCELERATION)
	#velocity.x = lerp(velocity.x,h*float(get_tree().get_first_node_in_group("Player").movement_speed),(delta)*ACCELERATION)
	
	#if get_tree().get_first_node_in_group("Player").animation_direction==0 && $raycast/z_negative.is_colliding():
		#velocity.z = get_tree().get_first_node_in_group("Player").velocity.z
	#if global_position.distance_to(get_tree().get_first_node_in_group("Player").position)<0.5:
		#velocity.z = lerp(velocity.z,v*float(get_tree().get_first_node_in_group("Player").movement_speed*4),(delta)*ACCELERATION)
		#velocity.x = lerp(velocity.x,h*float(get_tree().get_first_node_in_group("Player").movement_speed*4),(delta)*ACCELERATION)
	if $bucket_collision/collision_area.is_colliding():
		print($bucket_collision/collision_area.get_collision_normal(0))
	move_and_slide()
