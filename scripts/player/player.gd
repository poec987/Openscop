extends CharacterBody3D

# MOVEMENT VARIABLES

const MOVEMENT_SPEED = 5
const ACCELERATION = 10
var is_walking = false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# ANIMATION VARIABLES
const SPRITESHEET_ROWS = 5 # animations
const SPRITESHEET_COLUMNS = 4 # frames per animation
const ANIMATION_SPEED = 8
const ANIMATION_THRESHOLD = 0.1
var animation_direction = 0

var current_frame = 0

@onready var material = get_node("sprite").get_surface_override_material(0)
@onready var collision_box = get_node("collision")

func _physics_process(delta):
	var input_direction = Input.get_vector("pressed_right", "pressed_left", "pressed_up", "pressed_down")

	var v = Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")
	var h = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	if Vector3(velocity.x,0,velocity.z).length()>ANIMATION_THRESHOLD:
		is_walking=true
	else:
		is_walking=false
	
	var magnitude = sqrt(h*h + v*v)
	if magnitude > 1:
		h /= magnitude
		v /= magnitude
		
	velocity.x = lerp(velocity.x,h*MOVEMENT_SPEED,(delta)*ACCELERATION)
	velocity.z = lerp(velocity.z,v*MOVEMENT_SPEED,(delta)*ACCELERATION)
	
	#LEFT
	if h > 0:
		animation_direction=0
	elif h < 0:
		animation_direction=3
	if v > 0:
		animation_direction=2
	elif v < 0:
		animation_direction=1
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()

	if is_walking==false:
		material.uv1_offset = Vector3((animation_direction*(1.00/SPRITESHEET_COLUMNS)), (0*(1.00/SPRITESHEET_ROWS)), 0)
	if is_walking:
		current_frame+=0.2
		material.uv1_offset = Vector3((animation_direction*(1.00/SPRITESHEET_COLUMNS)), (floor(current_frame)*(1.00/SPRITESHEET_ROWS-1)+1), 0)
