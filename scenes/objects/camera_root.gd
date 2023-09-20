extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var distance = 2.6
	var cam_speed = 4.6
	if (position - get_node("../player").get_position()).length()>distance:
		position = lerp(position, get_node("../player").get_position(), get_node("../player").SPEED/cam_speed*delta)
	else:
		position = lerp(position, get_node("../player").get_position(), get_node("../player").SPEED/cam_speed*delta)
