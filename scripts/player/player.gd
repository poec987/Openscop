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

func _ready():
	# ANIMATION VARIABLES
	material.hframes = get_node("sprite").texture.get_size().x/64 # frames per ani mation
	material.vframes = get_node("sprite").texture.get_size().y/64 # animations

func change_sound(sound):

	if str(footstep_sound.stream.get_path())!=sound:
		footstep_sound.stream = load("res://sfx/walk_even_care.mp3")
func _physics_process(delta):
	RenderingServer.global_shader_parameter_set("player_pos", position)
	if not is_multiplayer_authority():return
	var v = Input.get_action_strength("pressed_left") - Input.get_action_strength("pressed_right")
	var h = Input.get_action_strength("pressed_down") - Input.get_action_strength("pressed_up")
	
	if Vector3(velocity.x,0,velocity.z).length()>ANIMATION_THRESHOLD:
		is_walking=true
		if is_on_floor() || position.y<0.2:
			if str(footstep_controller.get_collider()).get_slice(":", 0)=="grass":
				change_sound("res://sfx/walk_even_care.mp3")
	else:
		is_walking=false
	
	if Vector3(velocity.x,0,velocity.z).length()>0.1:
		 if !footstep_sound.playing:
			footstep_sound.play()
	
	var magnitude = sqrt(h*h + v*v)
	if magnitude > 1:
		h /= magnitude
		v /= magnitude
	
	if Global.control_mode==0:
		velocity.x = lerp(velocity.x,h*MOVEMENT_SPEED,(delta)*ACCELERATION)
		velocity.z = lerp(velocity.z,v*MOVEMENT_SPEED,(delta)*ACCELERATION)
	
	if material.hframes==4 || material.hframes == 5 && Global.control_mode==0:
		if h > 0:
			animation_direction=0
		elif h < 0:
			animation_direction=3
		
		if v > 0:
			animation_direction=2
		elif v < 0:
			animation_direction=1
	elif material.hframes==8 || material.hframes==9 && Global.control_mode==0:
		if h > 0 && v==0:
			animation_direction=0
		elif h < 0 && v==0:
			animation_direction=4
		elif h > 0 && v > 0:
			animation_direction=7
		elif h < 0 && v > 0:
			animation_direction=5
		elif v < 0 && h > 0:
			animation_direction=1
		elif v < 0 && h < 0:
			animation_direction=3
		elif v < 0 && h < 0:
			animation_direction=7
		elif v > 0 && h==0:
			animation_direction=6
		elif v < 0 && h==0:
			animation_direction=2
			
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
		current_frame=0
		if material.hframes>2:
			animation_direction = material.hframes-1
		elif material.hframes>1:
			animation_direction = 1
		if head.hframes!=1:
			head.frame_coords= Vector2(1,0)

	move_and_slide()
	if position.y <= 0:
		velocity.y = 0
		position.y = 0.01
		
	if is_walking==false:
		material.frame_coords = Vector2(animation_direction, 0)
		current_frame=1
		footstep_sound.stop()
	else:
		if material.hframes==1 || material.hframes==2 && Global.control_mode==0:
				animation_direction=0
		head.frame_coords= Vector2(0,0)
		material.vframes = int(material.texture.get_size().y)/(int(material.texture.get_size().x)/material.hframes) # animations
		current_frame+=ANIMATION_SPEED*delta
		if current_frame>material.vframes:
			if !first_frame && material.vframes>1:
				current_frame=1
			else:
				current_frame=0

		material.frame_coords = Vector2(animation_direction, floor(current_frame))


func _on_open_sheets_file_selected(path):
	var image = Image.new()
	image.load(path)
	var image_texture = ImageTexture.new()
	image_texture.set_image(image)
	var settings = ""
	if int(image_texture.get_size().x)%64!=0 || int(image_texture.get_size().y)%64!=0 || int(image_texture.get_size().x)%2!=0 || int(image_texture.get_size().y)%2!=0: 
		reset_sheet()
		OS.alert("This sheet has an uneven resolution.")
	else:
		if "head_.png" in path:
			head.texture = image_texture
			head.get_material_override().set_shader_parameter("albedoTex", head.texture)
			if image_texture.get_size().x==image_texture.get_size().y*2:
				head.hframes=2
			else:
				head.hframes=1
			material.texture = load("res://graphics/sprites/player/headless.png")
			material.get_material_override().set_shader_parameter("albedoTex", material.texture)
			material.hframes = 5
			material.vframes = 5
		else:
			head.texture = load("res://graphics/sprites/player/none.png")
			if Global.sheets.file_exists(ProjectSettings.globalize_path(path).replace(".png",".txt")):
				settings = FileAccess.get_file_as_string(ProjectSettings.globalize_path(path).replace(".png",".txt"))
				material.hframes = image_texture.get_size().x/(int(settings.get_slice("/", 0)))
				material.vframes = image_texture.get_size().y/(int(settings.get_slice("/", 0)))
				first_frame = bool(int(settings.get_slice("/", 1)))
				var player_scale = float(settings.get_slice("/", 2))
				scale=Vector3(player_scale,player_scale,player_scale)
			else:
				material.hframes = image_texture.get_size().x/64
				material.vframes = image_texture.get_size().y/64
				scale=Vector3(1.0,1.0,1.0)
			material.texture = image_texture
			material.get_material_override().set_shader_parameter("albedoTex", material.texture)
			head.get_material_override().set_shader_parameter("albedoTex", head.texture)
		material.frame_coords = Vector2(0,0)
	
	if int(material.texture.get_size().x)>576 && int(material.texture.get_size().y)>576:
		reset_sheet()
		OS.alert("Sheet resolution is too big.")
	
func reset_sheet():
	animation_direction=0
	material.texture = load("res://graphics/sprites/player/guardian.png")
	head.texture = load("res://graphics/sprites/player/none.png")
	material.get_material_override().set_shader_parameter("albedoTex", material.texture)
	head.get_material_override().set_shader_parameter("albedoTex", head.texture)
	material.hframes = 5
	material.vframes = 5
	scale=Vector3(1.0,1.0,1.0)
