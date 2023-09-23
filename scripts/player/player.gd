extends CharacterBody3D

# MOVEMENT VARIABLES

const MOVEMENT_SPEED = 5
const ACCELERATION = 8
var is_walking = false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# ANIMATION VARIABLES
@onready var spritesheet_columns = int(get_node("sprite").get_surface_override_material(0).albedo_texture.get_size().x) # frames per animation
@onready var spritesheet_rows = int(get_node("sprite").get_surface_override_material(0).albedo_texture.get_size().y)/(int(get_node("sprite").get_surface_override_material(0).albedo_texture.get_size().x)/spritesheet_columns) # animations

var disable_first_frame = true
const ANIMATION_SPEED = 8
const ANIMATION_THRESHOLD = 2
var animation_direction = 0

var current_frame = 0

@onready var material = get_node("sprite").get_surface_override_material(0)
	
func _physics_process(delta):
	#print(int(get_node("sprite").get_surface_override_material(0).albedo_texture.get_size().y)/(int(get_node("sprite").get_surface_override_material(0).albedo_texture.get_size().x)/spritesheet_columns))
	#DETECT SPRITESHEET SIZE AUTOMATICALLY
	if spritesheet_columns%4==0:
		spritesheet_columns = 4
	else:
		spritesheet_columns = 8

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
		material.uv1_offset = Vector3((animation_direction*(1.00/spritesheet_columns)), (0*(1.00/spritesheet_rows)), 0)
	else:
		spritesheet_rows = int(get_node("sprite").get_surface_override_material(0).albedo_texture.get_size().y)/(int(get_node("sprite").get_surface_override_material(0).albedo_texture.get_size().x)/spritesheet_columns) # animations
		current_frame+=ANIMATION_SPEED*delta
		if current_frame>spritesheet_rows:
			if disable_first_frame:
				current_frame=1
			else:
				current_frame=0
	
		#print(floor(current_frame) * (1.00 / spritesheet_rows))
		#print(floor(current_frame) * (1.00 / 5))
		material.uv1_offset = Vector3((animation_direction * (1.00 / spritesheet_columns)), (floor(current_frame) * (1.00 / spritesheet_rows)), 0)
