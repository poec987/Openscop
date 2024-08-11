extends CharacterBody3D

#COMMENT

# MOVEMENT VARIABLES

var movement_speed = 5
const ACCELERATION = 8
@export var is_walking = false
@export	var v = 0.0
@export	var h = 0.0
@export var current_footstep = 0
#GRAVITY WAS REMOVED DUE TO IT NOT EXISTING IN PETSCOP
#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

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

#RECORDING PROPERTIES
@export var recordingFile = ""

#PLAYBACK VARS
var replay = false
var replay_setup = false
var recording_finished = false
var recording = false
var recording_timer = false
var recording_data = {}
var recording_reader_p1 = 0
var recording_reader_p2 = 0

var upstr = 0.0
var downstr = 0.0
var leftstr = 0.0
var rightstr = 0.0

var in_p2 = false

#PLAYER SPRITE RELATED OBJECTS
@onready var material = get_node("sprite")
@onready var head = get_node("sprite/head")

#CURRENT PLAYER OBJECT
@export var character = 0
func allow_typing():
	can_submit=true
	
#PHYSICS PROCESS

func _ready():
	
	character = get_parent().get_meta("Character")
	recordingFile = get_parent().get_meta("recordingFile")
	Global.update_sheets = true
	
	return_character()
	load_recording(recordingFile, get_parent().get_meta("autoReplay"))
	if Global.retrace_steps:
		movement_speed = movement_speed*-1
	material.texture = material.get_material_override().get_shader_parameter("albedoTex")
	if material.hframes!= material.texture.get_size().x/64:
		material.hframes = material.texture.get_size().x/64
		material.vframes = material.texture.get_size().y/64
	if Global.gen<=2:
		set_collision_mask(0)
		
	if (get_parent().get_meta("enableSheet")):
		use_sheet(get_parent().get_meta("sheetPath"))
	
	if (get_parent().get_meta("replayAfterInit") && !get_parent().get_meta("autoReplay")):
		replay = true

#TO-DO: ORGANIZE PROPERLY

func _process(delta):
	if replay:
		if !replay_setup:
			recording_finished = false
			recording = false
			recording_timer = 0
			Console.console_log("[color=green]Loading Recording Data...[/color]")
			replay_setup = true
		if replay_setup:
			recording_timer+=1
		
		if recording_data["p1_data"].find(str(recording_timer)+"_END")!=-1:
			finish_replay()
		else:	
			#R1,R2,L1,L2,UP,DOWN,LEFT,RIGHT,Crs,Tri,Cir,Squ,Sel,Sta			
			if recording_reader_p1<=recording_data["p1_data"].size()-1:
				if recording_timer==int((recording_data["p1_data"][recording_reader_p1].split("_"))[0]):
					if int((recording_data["p1_data"][recording_reader_p1].split("_"))[5])!=0:
						if (number_parser(int((recording_data["p1_data"][recording_reader_p1].split("_"))[5]))):
							upstr = 1.0
						else:
							upstr = 0.0
					if int((recording_data["p1_data"][recording_reader_p1].split("_"))[6])!=0:
						if (number_parser(int((recording_data["p1_data"][recording_reader_p1].split("_"))[6]))):
							downstr = 1.0
						else:
							downstr = 0.0
					if int((recording_data["p1_data"][recording_reader_p1].split("_"))[7])!=0:
						if (number_parser(int((recording_data["p1_data"][recording_reader_p1].split("_"))[7]))):
							leftstr = 1.0
						else:
							leftstr = 0.0
					if int((recording_data["p1_data"][recording_reader_p1].split("_"))[8])!=0:	
						if (number_parser(int((recording_data["p1_data"][recording_reader_p1].split("_"))[8]))):
							rightstr = 1.0
						else:
							rightstr = 0.0
					if int((recording_data["p1_data"][recording_reader_p1].split("_"))[13])!=0:	
						if (number_parser(int((recording_data["p1_data"][recording_reader_p1].split("_"))[13])) && in_p2):
							if word!="":
								word = word.erase(word.length()-1,1)
							create_word()
							word = ""
							last_press = ""
							p2_talk.text = ""
							can_submit = false
					if Console.recording_parse:
						Console.console_log("[color=green]PLAYER 1[/color][color=yellow]Frame: "+str(recording_timer)+" Data:"+recording_data["p1_data"][recording_reader_p1]+" Index: "+str(recording_reader_p1)+"[/color]")
					recording_reader_p1+=1
				else:
					if Console.recording_parse:
						Console.console_log("[color=green]PLAYER 1[/color][color=yellow]Frame: "+str(recording_timer)+" Data: [/color][color=red]NONE[/color]")
			
			if recording_reader_p2<=recording_data["p2_data"].size()-1:
				if recording_timer==int((recording_data["p2_data"][recording_reader_p2].split("_"))[0]):
					in_p2 = true
					word = (recording_data["p2_data"][recording_reader_p2].split("_"))[1]
					$p2_talk_buttons.text = (recording_data["p2_data"][recording_reader_p2].split("_"))[2]
					if Console.recording_parse:
						Console.console_log("[color=green]PLAYER 2[/color][color=yellow]Frame: "+str(recording_timer)+" Data:"+recording_data["p2_data"][recording_reader_p2]+" Index: "+str(recording_reader_p2)+"[/color]")
					recording_reader_p2+=1
				else:
					in_p2 = false
					if Console.recording_parse:
						Console.console_log("[color=green]PLAYER 2[/color][color=yellow]Frame: "+str(recording_timer)+" Data: [/color][color=red]NONE[/color]")

func _physics_process(delta):
	material.get_material_override().set_shader_parameter("modulate_color",Vector4(Global.player_brightness,Global.player_brightness,Global.player_brightness,1.0))
	#VARIABLE DEFINES IF FOG SHOULD FOLLOW PLAYER OR NOT
	#WILL BE USED LATER ON FOR THINGS LIKE WINDMILL EVENT AND BASEMENT MACHINE
	#USELESS FOR NOW
	if Global.fog_focus==0:
		RenderingServer.global_shader_parameter_set("player_pos",global_position)

	var direction = Vector3()
	#CONTROL MODE 0: CONTROL PLAYER NORMALLY
	if Global.control_mode==0 || Global.control_mode==4 || Global.control_mode==1:
		#CREATES MOVEMENT VECTORS
		v = downstr - upstr
		h = rightstr - leftstr
		
	#DETECTS IF PLAYER IS WALKING BEFORE ANIMATING AND MAKE FOOTSTEP SOUND
	if Vector3(velocity.x,0,velocity.z).length()>ANIMATION_THRESHOLD:
		is_walking=true
		#DETECTS IF PLAYER IS ON FLOOR OR Y0, DEFINES SURFACE TYPE AND SETS FOOTSTEP SOUND
	else:
		#IF SPEED NOT FASTER THAN 0.2, DISABLE WALKING ANIM
		is_walking=false
	
		
	#REGULATES PLAYER SPEED SO IT DOESNT GO FASTER WHEN WALKING ON DIAGONALS
	var magnitude = sqrt(h*h + v*v)
	if magnitude > 1:
		h /= magnitude
		v /= magnitude
	
	if Global.control_mode==0 || Global.control_mode==1:
		#SETS PLAYER VELOCITY ACCORDING TO VECTOR
		if Global.current_character==2:
			velocity.x = lerp(velocity.x,h*-1*movement_speed,(delta)*ACCELERATION)
		else:
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
			#footstep_sound.stop()
		else:
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

func return_character():
	if Global.current_character==0:
		if Global.gen<=2:
			material.texture = load("res://graphics/sprites/player/gen_1.png")
		else:
			material.texture = load("res://graphics/sprites/player/guardian.png")
	if Global.current_character==1 && Global.update_sheets:
		material.texture = load("res://graphics/sprites/player/belle.png")
	if Global.current_character==2:
		if Global.update_sheets:
			material.texture = load("res://graphics/sprites/player/marvin.png")
		movement_speed = 6
	else:
		movement_speed = 5
	character = Global.current_character
	material.get_material_override().set_shader_parameter("albedoTex", material.texture)
	#RESETS CHARACTER
	
			
func reset_sheet():
	material.hframes = 5
	material.vframes = 5
	return_character()
	head.texture = load("res://graphics/sprites/player/none.png")
	material.get_material_override().set_shader_parameter("albedoTex", material.texture)
	head.get_material_override().set_shader_parameter("albedoTex", head.texture)
	
func use_sheet(path):
	#PNG HAS TO BE TURNED INTO TEXTURE AND LOADED INTO VRAM BEFORE BEING APPLIED
	var image = Image.new()
	image.load(path)
	var image_texture = ImageTexture.new()
	image_texture.set_image(image)
	#CHECK IF HEADSHEET, OR ELSE ITS PLAYER HEADSHEET
	material.material_override = material.material_override.duplicate()
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

func finish_replay():
	Console.console_log("[color=red]RECORDING IS OVER[/color]")
	replay = false
	replay_setup = false
	recording_timer = 0
	recording_reader_p1 = 0
	recording_reader_p2 = 0
	recording_finished = true
	recording_data = {}
	get_parent().queue_free()

func load_recording(file, autoreplay):
	recording_timer = 0
	recording_data = JSON.parse_string((FileAccess.open("user://recordings/"+file+".rec",FileAccess.READ)).get_as_text())
	if (!get_parent().get_meta("manualPosition")):
		position = Vector3(recording_data["save_data"]["player"]["coords"][0],recording_data["save_data"]["player"]["coords"][1],recording_data["save_data"]["player"]["coords"][2])
		animation_direction = int(recording_data["save_data"]["player"]["coords"][3])
	replay=autoreplay

func number_parser(number):
	if number==1:
		return true
	if number==2:
		return false

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
