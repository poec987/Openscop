extends CharacterBody3D

# MOVEMENT VARIABLES

var movement_speed = 5
const ACCELERATION = 8
@export var is_walking = false
@export	var v = 0.0
@export	var h = 0.0


#GRAVITY WAS REMOVED DUE TO IT NOT EXISTING IN PETSCOP
#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#ANIMATION PROPERTIES
var first_frame = false
const ANIMATION_SPEED = 8
const ANIMATION_THRESHOLD = 2
@export var animation_direction = 0
var current_frame = 0

#P2TOTALK RELATED VARIABLES AND OBJECTS
var word = ""
var last_press = ""
var can_submit = true
@onready var p2_talk = get_node("p2_talk_buttons")
@onready var p2_talk_word = preload("res://scenes/objects/setup/player/p2_talk_word.tscn")


#PLAYER SPRITE RELATED OBJECTS
@onready var material = get_node("sprite")
@onready var head = get_node("sprite/head")

#FOOTSTEP RELATED OBJECTS
@onready var footstep_controller = get_node("footstep_controller")
@onready var footstep_sound = get_node("footstep")
@onready var player_camera = get_tree().get_first_node_in_group("Player_camera")

#CURRENT PLAYER OBJECT
@export var character = 0
func allow_typing():
	can_submit=true

#CODE THAT CHANGES FOOTSTEP SOUND
func change_sound(sound):
	if str(footstep_sound.stream.get_path())!=sound:
		footstep_sound.stream = load(sound)
#PHYSICS PROCESS

func _ready():
	return_character()
	position = Vector3(Global.player_array.x,Global.player_array.y,Global.player_array.z)
	player_camera.position=position
	animation_direction = int(Global.player_array.w)
#TO-DO: ORGANIZE PROPERLY
func _physics_process(delta):
	material.get_material_override().set_shader_parameter("modulate_color",Vector4(Global.player_brightness,Global.player_brightness,Global.player_brightness,1.0))
	#VARIABLE DEFINES IF FOG SHOULD FOLLOW PLAYER OR NOT
	#WILL BE USED LATER ON FOR THINGS LIKE WINDMILL EVENT AND BASEMENT MACHINE
	#USELESS FOR NOW
	if Global.fog_focus==0:
		RenderingServer.global_shader_parameter_set("player_pos",global_position)

	var direction = Vector3()
	
	#CONTROL MODE 0: CONTROL PLAYER NORMALLY
	if Global.control_mode==0 || Global.control_mode==4:
		#CREATES MOVEMENT VECTORS
		v = Input.get_action_strength("pressed_down") - Input.get_action_strength("pressed_up")
		h = Input.get_action_strength("pressed_right") - Input.get_action_strength("pressed_left")

	#DETECTS IF PLAYER IS WALKING BEFORE ANIMATING AND MAKE FOOTSTEP SOUND
	if Vector3(velocity.x,0,velocity.z).length()>ANIMATION_THRESHOLD:
		if material.hframes>1 && material.vframes>1:
			if !footstep_sound.playing:
				if footstep_sound.stream_paused:
					footstep_sound.stream_paused=false
				else:
					footstep_sound.playing=true
			create_tween().tween_property(footstep_sound,"volume_db",80.0,0.5)
		is_walking=true
		#DETECTS IF PLAYER IS ON FLOOR OR Y0, DEFINES SURFACE TYPE AND SETS FOOTSTEP SOUND
		if is_on_floor() || position.y==0.0:
			#CHECKS IF BELOW PLAYER THERE'S MESH WITH THESE NAMES
			if footstep_controller.get_collider()!=null:
				if str(footstep_controller.get_collider().name)=="grass":
					change_sound("res://sfx/player/grass.wav")
				if str(footstep_controller.get_collider().name)=="evencare":
					change_sound("res://sfx/player/ec_steps.wav")
				if str(footstep_controller.get_collider().name)=="cement":
					change_sound("res://sfx/player/cement.wav")
				if str(footstep_controller.get_collider().name)=="cement2":
					change_sound("res://sfx/player/cement2.wav")
				if str(footstep_controller.get_collider().name)=="cement3":
					change_sound("res://sfx/player/cement3.wav")
				if str(footstep_controller.get_collider().name)=="school":
					change_sound("res://sfx/player/school_steps.wav")
				if str(footstep_controller.get_collider().name)=="sand":
					change_sound("res://sfx/player/sand_steps.wav")
	else:
		#IF SPEED NOT FASTER THAN 0.2, DISABLE WALKING ANIM
		is_walking=false
		
		
	if footstep_sound.volume_db<-79.0:
		footstep_sound.stream_paused=true
		
	#REGULATES PLAYER SPEED SO IT DOESNT GO FASTER WHEN WALKING ON DIAGONALS
	var magnitude = sqrt(h*h + v*v)
	if magnitude > 1:
		h /= magnitude
		v /= magnitude
	
	if Global.control_mode==0:
		#SETS PLAYER VELOCITY ACCORDING TO VECTOR
		velocity.x = lerp(velocity.x,h*movement_speed,(delta)*ACCELERATION)
		velocity.z = lerp(velocity.z,v*movement_speed,(delta)*ACCELERATION)
	else:
		velocity.x = lerp(velocity.x,0.*movement_speed,(delta)*ACCELERATION)
		velocity.z = lerp(velocity.z,0.*movement_speed,(delta)*ACCELERATION)
		
	if Global.control_mode==4:
		rotate_y(deg_to_rad(-h*10))
		direction.x = v
		direction = direction.rotated(Vector3(0,1,0),rotation.y)
		velocity.z = direction.z*(movement_speed*-1)
		velocity.x = direction.x*(movement_speed*-1)
		
	if Global.control_mode!=4 && Global.control_mode!=5:
		rotation.y=0


	if velocity.x<0.01 && velocity.x>-0.01:
		velocity.x=0.
	if velocity.z<0.01 && velocity.z>-0.01:
		velocity.z=0.
	
	#CHANGES PLAYER SPRITE DEPENDING ON DIRECTION
	if material.hframes>1 && material.vframes>1:
		if v > 0:
			animation_direction=0
		elif v < 0:
			animation_direction=3

		if h < 0:
			animation_direction=2
		elif h > 0:
			animation_direction=1
			
	
	#DOES HEAD BOPPING
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
	
#GRAVITY WAS REMOVED DUE TO IT NOT EXISTING IN PETSCOP
	#if not is_on_floor():
		#velocity.y -= gravity * delta
	
#HANDLES A BUNCH OF KEYBOARD SHORTCUTS
	if Input.is_action_just_released("sheet_hotkey"):
		get_node("../OpenSheets").show()
	if Input.is_action_just_pressed("default_char"):
		reset_sheet()
	if Input.is_action_just_pressed("change_mode"):
		if Global.control_mode%2==0:
			Global.control_mode+=1
		else:
			Global.control_mode-=1

		
		if Global.control_mode==1:
			get_node("mode_change").stop()
			get_node("mode_change").play()
#SUBMIT P2TOTALK WORD
	if Input.is_action_just_pressed("pressed_select") && p2_talk.text!="" && can_submit:
		if word!="":
			word = word.erase(word.length()-1,1)
		create_word()
		word = ""
		last_press = ""
		p2_talk.text = ""
		can_submit = false

#MOVES THE PLAYER
	move_and_slide()
		
#GRAVITY WAS REMOVED DUE TO IT NOT EXISTING IN PETSCOP	
	#if position.y <= 0:
		#velocity.y = 0
		#position.y = 0.01
#IF PLAYER IS NOT WALKING
	if material.hframes>1 && material.vframes>1:
		if is_walking==false:
			material.frame_coords = Vector2(animation_direction, 0)
			current_frame=0
			create_tween().tween_property(footstep_sound,"volume_db",-80.0,0.5)
			#footstep_sound.stop()
		else:
			if current_frame==0:
				create_tween().tween_property(footstep_sound,"volume_db",-80.0,0.5)
			#IF PLAYER IS WALKING
			head.frame_coords= Vector2(0,0)
			material.vframes = int(material.texture.get_size().y)/(int(material.texture.get_size().x)/material.hframes) # animations
			current_frame+=ANIMATION_SPEED*delta
			if current_frame>material.vframes:
				current_frame=1
		#UPDATE FRAMES
		material.frame_coords = Vector2(animation_direction, floor(current_frame))
	else:
		material.frame_coords = Vector2.ZERO

#IF PLAYER IS ON P2TOTALK MODE
	if Global.control_mode==1:
	#CONVERTS INPUTS TO PHONETICS
		if Input.is_action_just_pressed("pressed_action"):
			p2_talk.text+="5"
			if last_press=="L1":
				word+="S "
			elif last_press=="L2":
				word+="M "
			elif last_press=="R1":
				word+="EY "
			elif last_press=="R2":
				word+="UW "
			else:
				word+="AA "
			last_press = ""
			get_node("button_press").play()
		if Input.is_action_just_pressed("pressed_triangle"):
			p2_talk.text+="8"
			if last_press=="L1":
				word+="SH "
			elif last_press=="L2":
				word+="L "
			elif last_press=="R1":
				word+="IH "
			elif last_press=="R2":
				word+="B "
			else:
				word+="AO "
			last_press = ""
			get_node("button_press").play()
		if Input.is_action_just_pressed("pressed_circle"):
			p2_talk.text+="7"
			if last_press=="L1":
				word+="ZH "
			elif last_press=="L2":
				word+="R "
			elif last_press=="R1":
				word+="IY "
			elif last_press=="R2":
				word+="T "
			else:
				word+="AW "
			last_press = ""
			get_node("button_press").play()
		if Input.is_action_just_pressed("pressed_square"):
			p2_talk.text+="6"
			if last_press=="L1":
				word+="Z "
			elif last_press=="L2":
				word+="N "
			elif last_press=="R2":
				word+="P "
			else:
				word+="AE "
			last_press = ""
			get_node("button_press").play()
		if Input.is_action_just_pressed("pressed_up"):
			p2_talk.text+="@"
			if last_press=="L1":
				word+="JH "
			elif last_press=="L2":
				word+="Y "
			elif last_press=="R1":
				word+="OW "
			elif last_press=="R2":
				word+="F "
			else:
				word+="AY "
			last_press = ""
			get_node("button_press").play()
		if Input.is_action_just_pressed("pressed_down"):
			p2_talk.text+="#"
			if last_press=="L1":
				word+="K "
			elif last_press=="L2":
				word+="HH "
			elif last_press=="R1":
				word+="OY "
			elif last_press=="R2":
				word+="V "
			else:
				word+="AE "
			last_press = ""
			get_node("button_press").play()
		if Input.is_action_just_pressed("pressed_left"):
			p2_talk.text+="9"
			if last_press=="L1":
				word+="NG "
			elif last_press=="L2":
				word+="UH "
			elif last_press=="R2":
				word+="TH "
			else:
				word+="EH "
			last_press = ""
			get_node("button_press").play()
		if Input.is_action_just_pressed("pressed_right"):
			p2_talk.text+="!"
			if last_press=="L1":
				word+="G "
			elif last_press=="R1":
				word+="UH "
			elif last_press=="R2":
				word+="DH "
			else:
				word+="ER "
			last_press = ""
			get_node("button_press").play()
		if Input.is_action_just_pressed("pressed_l1"):
			p2_talk.text+="4"
			last_press="L1"
			get_node("button_press").play()
		if Input.is_action_just_pressed("pressed_l2"):
			p2_talk.text+="3"
			last_press="L2"
			get_node("button_press").play()
		if Input.is_action_just_pressed("pressed_r1"):
			p2_talk.text+="2"
			last_press="R1"
			get_node("button_press").play()
		if Input.is_action_just_pressed("pressed_r2"):
			p2_talk.text+="1"
			last_press="R2"
			get_node("button_press").play()
		if Input.is_action_just_pressed("pressed_start"):
			p2_talk.text+="$"
			if last_press=="L1":
				word+="CH "
			elif last_press=="L2":
				word+="W "
			elif last_press=="R2":
				word+="D "
			else:
				word+="AH "
			last_press = ""
			get_node("button_press").play()

#PROCESSES INPUTS SUBMITTED, CHECKS TABLE, AND SPAWNS FLOATING WORD
func create_word():
	#CREATES OBJECT OF FLOATING WORD
	var word_instance = p2_talk_word.instantiate()
	#CHECKS P2TOTALK TABLE AND SETS THE TEXT OF FLOATING WORD TO VALUE RETURNED
	#BY FUNCTION
	word_instance.text = Global.get_p2_word(word)
	#SPAWNS P2TOTALK WORD
	get_node("p2_talk_buttons/P2_talk").add_child(word_instance)
	
	#RESPONSIBLE FOR "CASCADE" EFFECT WHEN THERES MORE THAN 1 P2TALKWORD
	#ALSO RESPONSIBLE FOR ANIMATING THEM RISING
	var child_index = 0
	for words in get_node("p2_talk_buttons/P2_talk").get_children():
		if child_index!=get_node("p2_talk_buttons/P2_talk").get_child_count()-1:
			create_tween().tween_property(words, "position", Vector3(0, 0.5, 0), 1.0).set_trans(Tween.TRANS_LINEAR).as_relative()
		else:
			var tween = create_tween()
			tween.tween_property(words, "position", Vector3(0, 1.0, 0), 1.0).set_trans(Tween.TRANS_LINEAR).as_relative()
			tween.tween_callback(allow_typing)
		child_index+=1

#LOADS CUTSOM SHEETS
func _on_open_sheets_file_selected(path):
	#PNG HAS TO BE TURNED INTO TEXTURE AND LOADED INTO VRAM BEFORE BEING APPLIED
	var image = Image.new()
	image.load(path)
	var image_texture = ImageTexture.new()
	image_texture.set_image(image)
	#CHECK IF HEADSHEET, OR ELSE ITS PLAYER HEADSHEET
	if "head_.png" in path:
		head.texture = image_texture
		head.get_material_override().set_shader_parameter("albedoTex", head.texture)
		material.texture = load("res://graphics/sprites/player/headless.png")
		material.get_material_override().set_shader_parameter("albedoTex", material.texture)
	else:
		head.texture = load("res://graphics/sprites/player/none.png")
		material.texture = image_texture
		material.hframes = image_texture.get_size().x/64
		material.vframes = image_texture.get_size().y/64
		material.get_material_override().set_shader_parameter("albedoTex", material.texture)
		head.get_material_override().set_shader_parameter("albedoTex", head.texture)
func return_character():
	if Global.current_character==0:
		material.texture = load("res://graphics/sprites/player/guardian.png")
		material.get_material_override().set_shader_parameter("albedoTex", material.texture)
	if Global.current_character==1:
		material.texture = load("res://graphics/sprites/player/belle.png")
		material.get_material_override().set_shader_parameter("albedoTex", material.texture)
	if Global.current_character==2:
		material.texture = load("res://graphics/sprites/player/marvin.png")
		material.get_material_override().set_shader_parameter("albedoTex", material.texture)
		movement_speed = 8
	else:
		movement_speed = 5
	character = Global.current_character
#RESETS CHARACTER
func reset_sheet():
	material.hframes = 5
	material.vframes = 5
	return_character()
	head.texture = load("res://graphics/sprites/player/none.png")
	material.get_material_override().set_shader_parameter("albedoTex", material.texture)
	head.get_material_override().set_shader_parameter("albedoTex", head.texture)
