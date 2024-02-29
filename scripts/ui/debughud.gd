extends Control

func _process(_delta):
	if get_tree().get_first_node_in_group("Player")!=null: #IF THERE IS A PLAYER THIS CODE IS RAN
		$PlayerPos.text=str("Position: X:",snapped(get_tree().get_first_node_in_group("Player").position.x,0.0001)," Y:",snapped(get_tree().get_first_node_in_group("Player").position.y,0.0001)," Z:",snapped(get_tree().get_first_node_in_group("Player").position.z,0.0001),"\nDIR:",get_tree().get_first_node_in_group("Player").animation_direction)
		$PlayerVel.text=str("Velocity: X:",snapped(get_tree().get_first_node_in_group("Player").velocity.x,0.00001)," Y:",snapped(get_tree().get_first_node_in_group("Player").velocity.y,0.00001)," Z:",snapped(get_tree().get_first_node_in_group("Player").velocity.z,0.00001))
	else: #IF THERE IS NO PLAYER THIS CODE IS RAN
		$PlayerPos.text="NO PLAYER FOUND!"
		$PlayerVel.text=""
