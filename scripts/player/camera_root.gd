extends Node3D
#OBJECT THAT IS RESPONSIBLE FOR GUIDING CAMERA
const CAMERA_SPEED = 3.0
@onready var cam_anchor = $cam_anchor
@onready var cam = $cam_anchor/PSXLayer 
@onready var player = get_node("../player")

@export var pos_argument = Vector3.ZERO
@export var rot_argument = Vector3.ZERO
@export var smooth_out: float
func _setup():
	#SETS UP CAMERA ACCORDING TO ROOM, SPECIFIED PROPERTIES
	if Global.camera_mode==0:
		cam_anchor.position.z = Global.camera_dist_hor
		cam_anchor.position.y = Global.camera_dist_ver
		cam_anchor.rotation.x = (Global.camera_rot*0.01)*2
		if Global.cam_move_limit_x.x!=0.0 || Global.cam_move_limit_x.y!=0.0:
			position.x = clamp(position.x,Global.cam_move_limit_x.x,Global.cam_move_limit_x.y)
		if Global.cam_move_limit_z.x!=0.0 || Global.cam_move_limit_z.y!=0.0:
			position.z = clamp(position.z,Global.cam_move_limit_z.x,Global.cam_move_limit_z.y)
		if Global.cam_move_limit_y.x!=0.0 || Global.cam_move_limit_y.y!=0.0:
			position.y = clamp(position.y,Global.cam_move_limit_y.x,Global.cam_move_limit_y.y)
	if !Global.camera_move_x:
		position.x = Global.camera_freeze_x
	if !Global.camera_move_y:
		position.y = Global.camera_freeze_y
	if !Global.camera_move_z:
		position.z = Global.camera_freeze_z
func _process(delta):
	_setup()
	
	if rot_argument==null:
		rot_argument = cam_anchor.global_rotation
	
	#CAMERA MODE 0 = FOLLOW PLAYER	
	if Global.camera_mode==0:
		#EACH OF THESE CHECKS IF THE CAMERA IS TOO FAR FROM PLAYER DEPENDING ON SPECIFIED DISTNACE, AND IF CAMERA IS ALLOWED TO MOVE ON SPECIFIC AXIS.
		#THEN MOVE CAMERA TOWARDS PLAYER
		#LOTS OF FUNKY MATHEMATICS I FORGOT HOW THEY WORK
		if (abs(position.x-player.position.x) > Global.camera_limit_x) && Global.camera_move_x:
			position.x -= ((((position.x-player.position.x) / abs(position.x-player.position.x)))) * delta * abs(player.velocity.x)
		if (abs(position.z-player.position.z) > Global.camera_limit_z) && Global.camera_move_z:
			position.z -= ((((position.z-player.position.z) / abs(position.z-player.position.z)))) * delta * abs(player.velocity.z)
		if (abs(position.y-player.position.y) > Global.camera_limit_y) && Global.camera_move_y:
			position.y -= ((((position.y-player.position.y) / abs(position.y-player.position.y)))) * delta * abs(player.velocity.y)
		# set the pos and rot of the camera to follow the cam anchor
	_setup()
	
	if Global.camera_mode==0:
		if smooth_out==-1.0 || smooth_out==null:
			if Global.control_mode<4:
				cam.set_cam_pos(cam_anchor.global_position, cam_anchor.global_rotation)
			elif Global.control_mode>=4 && Global.control_mode<=5:
				cam.set_cam_pos(Vector3(get_tree().get_first_node_in_group("Player").global_position.x,1,get_tree().get_first_node_in_group("Player").global_position.z), Vector3(0.,-1.5708+get_tree().get_first_node_in_group("Player").rotation.y,0.))
		else:
			cam.set_cam_pos(pos_argument, rot_argument)
			pos_argument = pos_argument.lerp(cam_anchor.global_position,smooth_out*delta)
			rot_argument = rot_argument.lerp(cam_anchor.global_rotation,smooth_out*delta)
			player.rotation.y = rotation.y
			if cam.get_cam_pos()[0].distance_to(pos_argument)<0.01:
				smooth_out=-1.0
				
				
	#CAMERA MODE 1 = TRIPOD
	if Global.camera_mode==1:
		cam.set_cam_pos(pos_argument, rot_argument)
