extends Node3D

const CAMERA_SPEED = 3.0

@onready var player = get_node("../player")

func _process(delta):
	position = lerp(position, player.get_position(), CAMERA_SPEED * delta)
