extends Node3D
#OBJECT THAT IS RESPONSIBLE FOR GUIDING CAMERA
const CAMERA_SPEED = 3.0
@onready var cam_anchor = $cam_anchor
@onready var cam = $cam_anchor/PSXLayer 
@onready var player = get_node("../player")

func _setup():
	#SETS UP CAMERA ACCORDING TO ROOM, SPECIFIED PROPERTIES
	if Global.camera_mode==0:
		cam_anchor.position.z = Global.camera_dist_hor
		cam_anchor.position.y = Global.camera_dist_ver
		cam_anchor.rotation.x = (Global.camera_rot*0.01)*2
	#print_debug("cam_pos: ", cam_anchor.global_position)

func _process(delta):
	_setup()
	#print_debug("cam_pos: ", cam_anchor.global_position)
	#CAMERA MODE 0 = FOLLOW PLAYER
	if Global.camera_mode==0:
		#EACH OF THESE CHECKS IF THE CAMERA IS TOO FAR FROM PLAYER DEPENDING ON SPECIFIED DISTNACE, AND IF CAMERA IS ALLOWED TO MOVE ON SPECIFIC AXIS.
		#THEN MOVE CAMERA TOWARDS PLAYER
		#LOTS OF FUNKY MATHEMATICS I FORGOT HOW THEY WORK
		
		if (abs(position.x-player.position.x) > Global.camera_limit_x) && Global.camera_move_x:
			position.x -= ((((position.x-player.position.x) / abs(position.x-player.position.x)))) * delta * abs(player.velocity.x)
			if Global.cam_move_limit_x.x!=0.0 || Global.cam_move_limit_x.y!=0.0:
				position.x = clamp(position.x,Global.cam_move_limit_x.x,Global.cam_move_limit_x.y)
		
		if (abs(position.z-player.position.z) > Global.camera_limit_z) && Global.camera_move_z:
			position.z -= ((((position.z-player.position.z) / abs(position.z-player.position.z)))) * delta * abs(player.velocity.z)
			if Global.cam_move_limit_z.x!=0.0 || Global.cam_move_limit_z.y!=0.0:
				position.z = clamp(position.z,Global.cam_move_limit_z.x,Global.cam_move_limit_z.y)
		
		if (abs(position.y-player.position.y) > Global.camera_limit_y) && Global.camera_move_y:
			position.y -= ((((position.y-player.position.y) / abs(position.y-player.position.y)))) * delta * abs(player.velocity.y)
			if Global.cam_move_limit_y.x!=0.0 || Global.cam_move_limit_y.y!=0.0:
				position.y = clamp(position.y,Global.cam_move_limit_y.x,Global.cam_move_limit_y.y)
		
		# set the pos and rot of the camera to follow the cam anchor
	if Global.control_mode<4:
		cam.set_cam_pos(cam_anchor.global_position, cam_anchor.global_rotation)
	elif Global.control_mode>=4 && Global.control_mode<=5:
			cam.set_cam_pos(Vector3(get_tree().get_first_node_in_group("Player").global_position.x,1,get_tree().get_first_node_in_group("Player").global_position.z), Vector3(0.,-1.5708+get_tree().get_first_node_in_group("Player").rotation.y,0.))
