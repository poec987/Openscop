extends CanvasLayer
#THIS PART WAS PROGRAMMED BY EONORANGE, I DO NOT KNOW HOW IT WORKS ~~~TECHMAN06/CHEDDAR1460
@onready var camera = $NTSC/NTSC_viewport/Dither/dither_view/player_camera
# this just returns the camera object
func get_cam() -> Camera3D: return camera
# this is the function to move the camera, since it is parented under a viewport, it's transform is set as 
# top level and will not move if the parent node moves, somewhere up the chain
func set_cam_pos(pos, rot):
	camera.global_position = pos
	camera.global_rotation = rot
	
# this sets the camera as the main one
func get_cam_pos():
	return [camera.global_position,camera.global_rotation]

func set_main(): camera.make_current()
