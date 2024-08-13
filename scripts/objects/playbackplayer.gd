extends CharacterBody3D

# MOVEMENT VARIABLES

var movement_speed = 5
const ACCELERATION = 8

@export_category("Player Playback Properties")
@export var delay = 0.0
@export var main_recording_folder = true
@export var recording_file = ""
@export var invisible_until_playback = false
var retrace_steps = false
var player_array = Vector4()
#CURRENT PLAYER OBJECT
@export_category("Character Properties")
@export var use_recording_character = false
@export var head_sheet: CompressedTexture2D
@export var character_sheet: CompressedTexture2D
@export var marvin_speed = false
@export var character = 0
@export_category("Misc. Variables")
@export var is_walking = false
@export	var v = 0
@export	var h = 0
@export var current_footstep = 0
@export var brightness = 1.0
#GRAVITY WAS REMOVED DUE TO IT NOT EXISTING IN PETSCOP
#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#RECORDING VARIABLES:
var recording_data = {}
var recording_timer = 0
var replay = false
var replay_setup = false
var recording_finished = false
var recording_reader_p1 = 0
var recording_reader_p2 = 0
var input_sim_action = false
#ANIMATION PROPERTIES
var first_frame = false
const ANIMATION_SPEED = 8
const ANIMATION_THRESHOLD = 1.5
@export var animation_direction = 0
var current_frame = 0

#P2TOTALK RELATED VARIABLES AND OBJECTS
var prev_text = ""
@export var word = ""
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

func allow_typing():
	can_submit=true

#CODE THAT CHANGES FOOTSTEP SOUND
func change_sound(sound):
	if str(footstep_sound.stream.get_path())!=sound:
		footstep_sound.stream = load(sound)
#PHYSICS PROCESS

func _ready():
	recording_timer = 0
	if main_recording_folder:
		recording_data = JSON.parse_string((FileAccess.open("user://recordings/"+recording_file+".rec",FileAccess.READ)).get_as_text())
	else:
		recording_data = JSON.parse_string((FileAccess.open("user://player_recordings/"+recording_file+".rec",FileAccess.READ)).get_as_text())
	Console.console_log("[color=green]Loading Player Playback Data from Recording...[/color]")
	retrace_steps = recording_data["save_data"]["game"]["retrace_steps"]
	player_array = Vector4(recording_data["save_data"]["player"]["coords"][0],recording_data["save_data"]["player"]["coords"][1],recording_data["save_data"]["player"]["coords"][2],recording_data["save_data"]["player"]["coords"][3])
	brightness = recording_data["save_data"]["player"]["brightness"]
	#Global.key = recording_data["save_data"]["player"]["key"]
	if use_recording_character:
		character = recording_data["save_data"]["player"]["character"]
	Console.console_log("[color=blue]Loaded Player Playback Data from Recording sucessfully![/color]")
	#replay=true
	
	if !use_recording_character:
		if head_sheet==null:
			if character_sheet==null:
				if character==0:
					if Global.gen<=2:
						material.texture = load("res://graphics/sprites/player/gen_1.png")
					else:
						material.texture = load("res://graphics/sprites/player/guardian.png")
				if character==1:
					material.texture = load("res://graphics/sprites/player/belle.png")
				if character==2:
					material.texture = load("res://graphics/sprites/player/marvin.png")
			else:
				material.texture = character_sheet
		else:
			material.texture = load("res://graphics/sprites/player/headless.png")
			head.texture = head_sheet
		
		if marvin_speed or character==2:
			movement_speed = 6
		else:
			movement_speed = 5
	
	material.get_material_override().set_shader_parameter("albedoTex", material.texture)
	global_position = Vector3(player_array.x,player_array.y,player_array.z)
	Global.current_player = Vector4(position.x,position.y,position.z,animation_direction)
	player_camera.position=position
	animation_direction = int(player_array.w)
	if retrace_steps:
		movement_speed = movement_speed*-1
	material.texture = material.get_material_override().get_shader_parameter("albedoTex")
	if material.hframes!= material.texture.get_size().x/64:
		material.hframes = material.texture.get_size().x/64
		material.vframes = material.texture.get_size().y/64
	if Global.gen<=2:
		set_collision_mask(0)

#TO-DO: ORGANIZE PROPERLY
func _physics_process(delta):
	if replay:
		if !replay_setup:
			recording_finished = false
			recording_timer = 0
			Console.console_log("[color=green]Loading Recording Data...[/color]")
			replay_setup = true
		if replay_setup:
			recording_timer+=1
		if recording_data["p1_data"].find(str(recording_timer)+"_END")!=-1:
			finish_replay()
		else:
			#UP,DOWN,LEFT,RIGHT,Crs
			if recording_reader_p1<=recording_data["p1_data"].size()-1:
				if recording_timer==int((recording_data["p1_data"][recording_reader_p1].split("_"))[0]):
					if int((recording_data["p1_data"][recording_reader_p1].split("_"))[5])!=0:
						v = 1.0
					if int((recording_data["p1_data"][recording_reader_p1].split("_"))[6])!=0:
						v = -1.0
					if int((recording_data["p1_data"][recording_reader_p1].split("_"))[7])!=0:
						h = -1.0
					if int((recording_data["p1_data"][recording_reader_p1].split("_"))[8])!=0:	
						h = 1.0
					if int((recording_data["p1_data"][recording_reader_p1].split("_"))[9])!=0:	
						input_sim_action = true
						input_sim_action = false

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
					current_footstep=1
				if str(footstep_controller.get_collider().name)=="evencare":
					current_footstep=0
				if str(footstep_controller.get_collider().name)=="cement":
					current_footstep=2
				if str(footstep_controller.get_collider().name)=="cement2":
					current_footstep=3
				if str(footstep_controller.get_collider().name)=="cement3":
					current_footstep=4
				if str(footstep_controller.get_collider().name)=="school":
					current_footstep=5
				if str(footstep_controller.get_collider().name)=="sand":
					current_footstep=6
	else:
		#IF SPEED NOT FASTER THAN 0.2, DISABLE WALKING ANIM
		is_walking=false
	
	if current_footstep==0:
		change_sound("res://sfx/player/ec_steps.wav")
	if current_footstep==1:
		change_sound("res://sfx/player/grass.wav")
	if current_footstep==2:
		change_sound("res://sfx/player/cement.wav")
	if current_footstep==3:
		change_sound("res://sfx/player/cement2.wav")
	if current_footstep==4:
		change_sound("res://sfx/player/cement3.wav")
	if current_footstep==5:
		change_sound("res://sfx/player/school_steps.wav")
	if current_footstep==6:
		change_sound("res://sfx/player/sand_steps.wav")
		
	if footstep_sound.volume_db<-79.0:
		footstep_sound.stream_paused=true
		
	#REGULATES PLAYER SPEED SO IT DOESNT GO FASTER WHEN WALKING ON DIAGONALS
	var magnitude = sqrt(h*h + v*v)
	if magnitude > 1:
		h /= magnitude
		v /= magnitude
	
	if Global.control_mode==0:
		#SETS PLAYER VELOCITY ACCORDING TO VECTOR
		if Global.current_character==2:
			velocity.x = lerp(velocity.x,h*-1*movement_speed,(delta)*ACCELERATION)
		else:
			velocity.x = lerp(velocity.x,h*movement_speed,(delta)*ACCELERATION)
		velocity.z = lerp(velocity.z,v*movement_speed,(delta)*ACCELERATION)
	else:
		velocity.x = lerp(velocity.x,0.*movement_speed,(delta)*ACCELERATION)
		velocity.z = lerp(velocity.z,0.*movement_speed,(delta)*ACCELERATION)


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
			animation_direction=2-(int(Global.current_character==2))
		elif h > 0:
			animation_direction=1+(int(Global.current_character==2))
			
	
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

	if prev_text!=p2_talk.text && p2_talk.text!="":
		get_node("button_press").play()
		prev_text=p2_talk.text

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

		if Input.is_action_just_pressed("pressed_l1"):
			p2_talk.text+="4"
			last_press="L1"

		if Input.is_action_just_pressed("pressed_l2"):
			p2_talk.text+="3"
			last_press="L2"

		if Input.is_action_just_pressed("pressed_r1"):
			p2_talk.text+="2"
			last_press="R1"

		if Input.is_action_just_pressed("pressed_r2"):
			p2_talk.text+="1"
			last_press="R2"

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


#PROCESSES INPUTS SUBMITTED, CHECKS TABLE, AND SPAWNS FLOATING WORD
func create_word():
	#CREATES OBJECT OF FLOATING WORD
	var word_instance = p2_talk_word.instantiate()
	#CHECKS P2TOTALK TABLE AND SETS THE TEXT OF FLOATING WORD TO VALUE RETURNED
	#BY FUNCTION
	word_instance.text = Global.get_p2_word(word.rstrip(" "))
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
		
func number_parser(number):
	if number==1:
		return true
	if number==2:
		return false
		
func finish_replay():
	Console.console_log("[color=red]RECORDING IS OVER[/color]")
	replay = false
	replay_setup = false
	recording_timer = 0
	recording_reader_p1 = 0
	recording_finished = true
	recording_data = {}
