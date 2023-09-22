extends Node3D

const CAMERA_SPEED = 3.0

@onready var player = get_node("../player")

func _process(delta):
	if (abs(position.x-player.position.x) > Global.camera_limit_hor):
		position.x -= ((((position.x-player.position.x) / abs(position.x-player.position.x)))) * delta * abs(player.velocity.x)
	if (abs(position.z-player.position.z) > Global.camera_limit_ver):
		position.z -= ((((position.z-player.position.z) / abs(position.z-player.position.z)))) * delta * abs(player.velocity.z)
