extends CharacterBody3D

# MOVEMENT VARIABLES

const MOVEMENT_SPEED = 5
const ACCELERATION = 8
var is_walking = false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# ANIMATION VARIABLES
@onready var spritesheet_columns = get_node("sprite").get_surface_override_material(0).albedo_texture.get_size().x/64 # frames per animation
@onready var spritesheet_rows = get_node("sprite").get_surface_override_material(0).albedo_texture.get_size().y/64 # animations

#ANIMATION PROPERTIES
var first_frame = false
const ANIMATION_SPEED = 8
const ANIMATION_THRESHOLD = 2
var animation_direction = 0

#GAME MANAGEMENT
var directory = DirAccess.open("user://")
var sheets = DirAccess.open("user://sheets")

var current_frame = 0

@onready var material = get_node("sprite").get_surface_override_material(0)
	
	
func _ready():
	#set_multiplayer_authority(str(name).to_int())
	#if not is_multiplayer_authority():return
	#get_camera.current=true
	if !directory.dir_exists("sheets"):
		directory.make_dir("sheets")
	
	material.uv1_scale.x = 1.00/spritesheet_columns
	material.uv1_scale.y = 1.00/spritesheet_rows

func _physics_process(delta):
	if not is_multiplayer_authority():return
	var input_direction = Input.get_vector("pressed_right", "pressed_left", "pressed_up", "pressed_down")
	var v = Input.get_action_strength("pressed_left") - Input.get_action_strength("pressed_right")
	var h = Input.get_action_strength("pressed_down") - Input.get_action_strength("pressed_up")
	
	if Vector3(velocity.x,0,velocity.z).length()>ANIMATION_THRESHOLD:
		is_walking=true
	else:
		is_walking=false
	
	var magnitude = sqrt(h*h + v*v)
	if magnitude > 1:
		h /= magnitude
		v /= magnitude
	
	if Global.control_mode==0:
		velocity.x = lerp(velocity.x,h*MOVEMENT_SPEED,(delta)*ACCELERATION)
		velocity.z = lerp(velocity.z,v*MOVEMENT_SPEED,(delta)*ACCELERATION)
	
	if spritesheet_columns==4 || spritesheet_columns == 5 && Global.control_mode==0:
		if h > 0:
			animation_direction=0
		elif h < 0:
			animation_direction=3
		
		if v > 0:
			animation_direction=2
		elif v < 0:
			animation_direction=1
	elif spritesheet_columns==8 || spritesheet_columns==9 && Global.control_mode==0:
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
	elif spritesheet_columns==1 || spritesheet_columns==2 && Global.control_mode==0:
			animation_direction=0
			
	if	get_node("collision").position.y<0+(get_node("collision").shape.size.y/2):
			get_node("collision").position.y = 0+(get_node("collision").shape.size.y/2)
	
	# Add the gravity.
	if not is_on_floor():
		get_node("collision").velocity.y -= gravity * delta
			

	if Input.is_action_just_released("sheet_hotkey"):
		get_node("../OpenSheets").show()
	if Input.is_action_just_pressed ("oeptos") && int(spritesheet_columns)%2!=0 || spritesheet_columns==2:
		animation_direction = spritesheet_columns-1
	if Input.is_action_just_pressed("open_sheet_folder"):
		OS.shell_show_in_file_manager(ProjectSettings.globalize_path("user://sheets"),true)
	if Input.is_action_just_pressed("default_char"):
		reset_sheet()

	move_and_slide()
	if is_walking==false:
		material.uv1_offset = Vector3((animation_direction*(1.00/spritesheet_columns)), (0*(1.00/spritesheet_rows)), 0)
		current_frame=1
	else:
		spritesheet_rows = int(material.albedo_texture.get_size().y)/(int(material.albedo_texture.get_size().x)/spritesheet_columns) # animations
		current_frame+=ANIMATION_SPEED*delta
		if current_frame>spritesheet_rows:
			if !first_frame:
				current_frame=1
			else:
				current_frame=0

		material.uv1_offset = Vector3((animation_direction * (1.00 / spritesheet_columns)), (floor(current_frame) * (1.00 / spritesheet_rows)), 0)



func _on_open_sheets_file_selected(path):
	var image = Image.new()
	image.load(path)
	
	var image_texture = ImageTexture.new()
	image_texture.set_image(image)
	animation_direction=0
	material.albedo_texture = image_texture
	var settings = ""
	if sheets.file_exists(ProjectSettings.globalize_path(path).replace(".png",".txt")):
		settings = FileAccess.get_file_as_string(ProjectSettings.globalize_path(path).replace(".png",".txt"))
		spritesheet_columns = int(material.albedo_texture.get_size().x)/(int(settings.get_slice("/", 0)))
		spritesheet_rows = int(material.albedo_texture.get_size().y)/(int(settings.get_slice("/", 0)))
		material.uv1_scale.x = 1.00/spritesheet_columns
		material.uv1_scale.y = 1.00/spritesheet_rows
		first_frame = bool(int(settings.get_slice("/", 1)))
		var player_scale = float(settings.get_slice("/", 2))
		scale=Vector3(player_scale,player_scale,player_scale)
	else:
		spritesheet_columns = int(material.albedo_texture.get_size().x)/64
		spritesheet_rows = int(material.albedo_texture.get_size().y)/64
		material.uv1_scale.x = 1.00/spritesheet_columns
		material.uv1_scale.y = 1.00/spritesheet_rows
		scale=Vector3(1.0,1.0,1.0)
		
	if spritesheet_columns==3 || spritesheet_columns==6 || spritesheet_columns==7 || spritesheet_columns>9:
		reset_sheet()
		OS.alert("This sheet has the wrong amount of columns.")
	
	if int(material.albedo_texture.get_size().x)%2!=0 || int(material.albedo_texture.get_size().y)%2!=0: 
		reset_sheet()
		OS.alert("This sheet has an uneven resolution.")
	
	if int(material.albedo_texture.get_size().x)>576 && int(material.albedo_texture.get_size().y)>576:
		reset_sheet()
		OS.alert("Sheet resolution is too big.")
	
func reset_sheet():
	animation_direction=0
	material.albedo_texture = load("res://graphics/sprites/player/guardian.png")
	spritesheet_columns = int(material.albedo_texture.get_size().x)/64
	spritesheet_rows = int(material.albedo_texture.get_size().y)/64
	material.uv1_scale.x = 1.00/spritesheet_columns
	material.uv1_scale.y = 1.00/spritesheet_rows
	scale=Vector3(1.0,1.0,1.0)
