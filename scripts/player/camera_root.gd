extends Node3D
#OBJECT THAT IS RESPONSIBLE FOR GUIDING CAMERA
const CAMERA_SPEED = 3.0
@onready var cam_anchor = $cam_anchor
@onready var cam = $cam_anchor/PSXLayer 
@onready var player = get_node("../player")

func _ready():
	_setup()

func _setup():
	#SETS UP CAMERA ACCORDING TO ROOM, SPECIFIED PROPERTIES
	if Global.camera_mode==0:
		cam_anchor.position.x = Global.camera_dist_hor
		cam_anchor.position.y = Global.camera_dist_ver
		cam_anchor.rotation.x = -0.18*2
	#print_debug("cam_pos: ", cam_anchor.global_position)

func _process(delta):
	#CAMERA MODE 0 = FOLLOW PLAYER
	if Global.camera_mode==0:
		#EACH OF THESE CHECKS IF THE CAMERA IS TOO FAR FROM PLAYER DEPENDING ON SPECIFIED DISTNACE, AND IF CAMERA IS ALLOWED TO MOVE ON SPECIFIC AXIS.
		#THEN MOVE CAMERA TOWARDS PLAYER
		#LOTS OF FUNKY MATHEMATICS I FORGOT HOW THEY WORK
		if (abs(position.x-player.position.x) > Global.camera_limit_x) && Global.camera_move_x:
			position.x -= ((((position.x-player.position.x) / abs(position.x-player.position.x)))) * delta * abs(player.velocity.x)
		if (abs(position.z-player.position.z) > Global.camera_limit_z) && Global.camera_move_z:
			position.z -= ((((position.z-player.position.z) / abs(position.z-player.position.z)))) * delta * abs(player.velocity.z)
		if (abs(position.z-player.position.z) > Global.camera_limit_y) && Global.camera_move_y:
			position.y -= ((((position.y-player.position.y) / abs(position.z-player.position.y)))) * delta * abs(player.velocity.y)
		# set the pos and rot of the camera to follow the cam anchor
		cam.set_cam_pos(cam_anchor.global_position, cam_anchor.global_rotation)
