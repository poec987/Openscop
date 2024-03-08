extends Node3D
var title_stage = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("pressed_start"):
		if $title_root.position.x==3.924:
			create_tween().tween_property($title_root,"position:x",3.5,0.75).set_trans(Tween.TRANS_SINE)
			#var scale_logo = create_tween()
