extends CharacterBody3D

# MOVEMENT VARIABLES

const MOVEMENT_SPEED = 5
const ACCELERATION = 8
var is_walking = false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# ANIMATION VARIABLES
@onready var spritesheet_columns = 4 # frames per animation
@onready var spritesheet_rows = 5 # animations

#ANIMATION PROPERTIES
var disable_first_frame = true
const ANIMATION_SPEED = 8
const ANIMATION_THRESHOLD = 2
var animation_direction = 0

#GAME MANAGEMENT
var directory = DirAccess.open("user://")
var sheets = DirAccess.open("user://sheets")

var current_frame = 0

@onready var material = get_node("sprite").get_surface_override_material(0)
	
func _ready():
	OS.shell_show_in_file_manager(ProjectSettings.globalize_path("user://sheets"),true)
	
	if !directory.dir_exists("sheets"):
		directory.make_dir("sheets")
	
	get_node("sprite").get_surface_override_material(0).uv1_scale.x = 1.00/spritesheet_columns
	get_node("sprite").get_surface_override_material(0).uv1_scale.y = 1.00/spritesheet_rows

func _physics_process(delta):
	var input_direction = Input.get_vector("pressed_right", "pressed_left", "pressed_up", "pressed_down")
	
	if Input.is_action_just_released("sheet_hotkey"):
		get_node("../OpenSheets").show()
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
	
	if spritesheet_columns==4 && Global.control_mode==0:
		if h > 0:
			animation_direction=0
		elif h < 0:
			animation_direction=3
		
		if v > 0:
			animation_direction=2
		elif v < 0:
			animation_direction=1
	else:
		if Global.control_mode==0:
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
		
	# Add the gravity.
	if not is_on_floor():
		if	position.y>0+(get_node("collision").shape.size.y/2):
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

		material.uv1_offset = Vector3((animation_direction * (1.00 / spritesheet_columns)), (floor(current_frame) * (1.00 / spritesheet_rows)), 0)

func _on_open_sheets_file_selected(path):
	var image_path = path
	var image = Image.new()
	image.load(image_path)
	
	var image_texture = ImageTexture.new()
	image_texture.set_image(image)
	get_node("sprite").get_surface_override_material(0).albedo_texture = image_texture
	
	var settings = ""
	if sheets.file_exists(ProjectSettings.globalize_path(path).replace(".png",".txt")):
		settings = FileAccess.get_file_as_string(ProjectSettings.globalize_path(path).replace(".png",".txt"))
		spritesheet_columns = int(settings.get_slice("/", 0))
		spritesheet_rows = int(settings.get_slice("/", 1))
		get_node("sprite").get_surface_override_material(0).uv1_scale.x = 1.00/spritesheet_columns
		get_node("sprite").get_surface_override_material(0).uv1_scale.y = 1.00/spritesheet_rows
		disable_first_frame = bool(int(settings.get_slice("/", 2)))
		var player_scale = float(settings.get_slice("/", 3))
		scale=Vector3(player_scale,player_scale,player_scale)
	else:
		spritesheet_columns = 4
		spritesheet_rows = 5
		scale=Vector3(1.0,1.0,1.0)
