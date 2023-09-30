extends Node3D

@onready var camera = get_node("player_camera")
@onready var player = get_node("../player")
func _ready():
	camera.position.x = Global.camera_dist_hor
	camera.position.y = Global.camera_dist_ver
	
func _process(delta):		
	if (abs(position.x-player.position.x) > Global.camera_limit_x) && Global.camera_move_x:
		position.x -= ((((position.x-player.position.x) / abs(position.x-player.position.x)))) * delta * abs(player.velocity.x)
	if (abs(position.z-player.position.z) > Global.camera_limit_z) && Global.camera_move_z:
		position.z -= ((((position.z-player.position.z) / abs(position.z-player.position.z)))) * delta * abs(player.velocity.z)
	if (abs(position.z-player.position.z) > Global.camera_limit_y) && Global.camera_move_y:
		position.y -= ((((position.y-player.position.y) / abs(position.z-player.position.y)))) * delta * abs(player.velocity.y)
		
func _setup():
	camera.position.x = Global.camera_dist_hor
	camera.position.y = Global.camera_dist_ver
	camera.rotation.x = Global.camera_rot
