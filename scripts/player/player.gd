extends CharacterBody3D

# MOVEMENT VARIABLES

const MOVEMENT_SPEED = 5
const ACCELERATION = 8
var is_walking = false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#ANIMATION PROPERTIES
var first_frame = false
const ANIMATION_SPEED = 8
const ANIMATION_THRESHOLD = 2
var animation_direction = 0

#GAME MANAGEMENT
var current_frame = 0

@onready var material = get_node("sprite")
@onready var head = get_node("head")
@onready var footstep_controller=get_node("footstep_controller")
@onready var footstep_sound=get_node("footstep")

func change_sound(sound):

	if str(footstep_sound.stream.get_path())!=sound:
		footstep_sound.stream = load(sound)
func _physics_process(delta):
	RenderingServer.global_shader_parameter_set("player_pos", position)

	var v = 0.0
	var h = 0.0
	if Global.control_mode==0:
		v = Input.get_action_strength("pressed_left") - Input.get_action_strength("pressed_right")
		h = Input.get_action_strength("pressed_down") - Input.get_action_strength("pressed_up")

	if Vector3(velocity.x,0,velocity.z).length()>ANIMATION_THRESHOLD:
		is_walking=true
		if is_on_floor() || position.y<0.2:
			if str(footstep_controller.get_collider()).get_slice(":", 0)=="grass":
				change_sound("res://sfx/grass.wav")
			if str(footstep_controller.get_collider()).get_slice(":", 0)=="evencare":
				change_sound("res://sfx/ec_steps.wav")
			if str(footstep_controller.get_collider()).get_slice(":", 0)=="cement":
				change_sound("res://sfx/cement.wav")
			if str(footstep_controller.get_collider()).get_slice(":", 0)=="cement2":
				change_sound("res://sfx/cement2.wav")
			if str(footstep_controller.get_collider()).get_slice(":", 0)=="cement3":
				change_sound("res://sfx/cement3.wav")
			if str(footstep_controller.get_collider()).get_slice(":", 0)=="school":
				change_sound("res://sfx/school_steps.wav")
	else:
		is_walking=false
	
	if Vector3(velocity.x,0,velocity.z).length()>0.1:
		if !footstep_sound.playing:
			footstep_sound.play()
	
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
			
	if	get_node("collision").position.y<0+(get_node("collision").shape.size.y/2):
			get_node("collision").position.y = 0+(get_node("collision").shape.size.y/2)
	
	if material.frame_coords.y==2 || material.frame_coords.y==4:
		head.offset.y=39
	else:
		head.offset.y=35
	if animation_direction==4:
		head.offset.y=36
	if animation_direction==2 || animation_direction==3:
		head.flip_h=true
	else:
		head.flip_h=false
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if Input.is_action_just_released("sheet_hotkey"):
		get_node("../OpenSheets").show()
	if Input.is_action_just_pressed("default_char"):
		reset_sheet()
	if Input.is_action_just_pressed("oeptos") && !is_walking:
		animation_direction=4
		
		
	move_and_slide()
		
	
	if position.y <= 0:
		velocity.y = 0
		position.y = 0.01
		
	if is_walking==false:
		material.frame_coords = Vector2(animation_direction, 0)
		current_frame=1
		footstep_sound.stop()
	else:
		head.frame_coords= Vector2(0,0)
		material.vframes = int(material.texture.get_size().y)/(int(material.texture.get_size().x)/material.hframes) # animations
		current_frame+=ANIMATION_SPEED*delta
		if current_frame>material.vframes:
			current_frame=1

		material.frame_coords = Vector2(animation_direction, floor(current_frame))


func _on_open_sheets_file_selected(path):
	var image = Image.new()
	image.load(path)
	var image_texture = ImageTexture.new()
	image_texture.set_image(image)
	if "head_.png" in path:
		head.texture = image_texture
		head.get_material_override().set_shader_parameter("albedoTex", head.texture)
		material.texture = load("res://graphics/sprites/player/headless.png")
		material.get_material_override().set_shader_parameter("albedoTex", material.texture)
	else:
		head.texture = load("res://graphics/sprites/player/none.png")
		material.texture = image_texture
		material.get_material_override().set_shader_parameter("albedoTex", material.texture)
		head.get_material_override().set_shader_parameter("albedoTex", head.texture)
	
func reset_sheet():
	material.texture = load("res://graphics/sprites/player/guardian.png")
	head.texture = load("res://graphics/sprites/player/none.png")
	material.get_material_override().set_shader_parameter("albedoTex", material.texture)
	head.get_material_override().set_shader_parameter("albedoTex", head.texture)
