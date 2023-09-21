extends CharacterBody3D

# MOVEMENT VARIABLES

const MOVEMENT_SPEED = 2.5
const ACCELERATION = 10
var is_walking = false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# ANIMATION VARIABLES
const SPRITESHEET_ROWS = 5 # animations
const SPRITESHEET_COLUMNS = 4 # frames per animation
const ANIMATION_SPEED = 8
const ANIMATION_THRESHOLD = 0.1
var ANIMATION_DIRECTION = 0

var ANIM_FRAME = 0

@onready var material = get_node("sprite").get_surface_override_material(0)
@onready var collision_box = get_node("collision")

func _physics_process(delta):
	var input_direction = Input.get_vector("pressed_right", "pressed_left", "pressed_up", "pressed_down")
	update_position(delta)
	
func update_position(delta):
	var v = Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")
	var h = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	velocity.x = lerp(velocity.x,h*MOVEMENT_SPEED,(delta)*ACCELERATION)
	velocity.z = lerp(velocity.z,v*MOVEMENT_SPEED,(delta)*ACCELERATION)
	
	if velocity.x>ANIMATION_THRESHOLD || velocity.z>ANIMATION_THRESHOLD || velocity.x>ANIMATION_THRESHOLD && velocity.z>ANIMATION_THRESHOLD:
		is_walking=true
	else:
		is_walking=false
	
	var magnitude = sqrt(h*h + v*v)
	if magnitude > 1:
		h /= magnitude
		v /= magnitude
	
	#LEFT
	if v==1.0 && h==0:
		ANIMATION_DIRECTION=2
	if v==1.0 && h==1.0:
		ANIMATION_DIRECTION=0
	if v==1.0 && h==-1.0:
		ANIMATION_DIRECTION=3
	
	#RIGHT
	if v==-1.0 && h==0.0:
		ANIMATION_DIRECTION=1
	if v==-1.0 && h==1.0:
		ANIMATION_DIRECTION=1
	if v==-1.0 && h==-1.0:
		ANIMATION_DIRECTION=3
		
	#FRONT
	if v==0.0 && h==1.0:
		ANIMATION_DIRECTION=0
		
	#BACK
	if v==0.0 && h==-1.0:
		ANIMATION_DIRECTION=3
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	# Handle Jump.
	#if Input.is_action_just_pressed("pressed_action") and is_on_floor():
	#	velocity.y = JUMP_VELOCITY

	move_and_slide()

	if is_walking!=false:
		ANIM_FRAME+=0.2
		if ANIM_FRAME>SPRITESHEET_ROWS:
			ANIM_FRAME=1
	if is_walking==false:
		ANIM_FRAME=0
	print(is_walking)
	if is_walking:
		material.uv1_offset = Vector3((ANIMATION_DIRECTION*(1.00/SPRITESHEET_COLUMNS)), (floor(ANIM_FRAME)*(1.00/SPRITESHEET_ROWS)), 0)
