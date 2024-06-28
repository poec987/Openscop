extends Node2D
#TEXTBOX OBJECT

#TYPEWRITER SPEEDS
const DEFAULT_WAIT = 0.025
const PUNCTUATION_WAIT = 0.150
const TYPING_SOUND_FADE_IN_TIME = 0.25
const TYPING_SOUND_VOLUME = 5.0
#CUSTOMIZABLE VARIABLES
@export var background = 0
@export var text = []
@export var big = false

#AMOUNT OF CHARS ON DISPLAY, PAGE OF TEXTBOX.
var chars = 0
var textbox = 0

#CHARACTERS THAT MAKE TYPEWRITER SLOWER
var slowchars="!.?,;"

#CHECK IF IS READY TO SKIP.
var textbox_stage = 0

@onready var dialogue_typing_sound = $dialogue_typing
@onready var textbox_content = $textbox_text
@onready var text_timer = $textbox_timer
@onready var text_background = $textbox_background
@onready var arrow = $textbox_arrow
@onready var change_box_sound = $dialogue_change
@onready var arrow_time = $arrow_timer


func _ready():
	if big:
		text_background.texture = load("res://graphics/sprites/ui/textbox_big.png")
		text_background.position.y=167
		textbox_content.position.y=134
	#SETS UP THE TEXTBOX BACKGROUND
	if background==0:
		$textbox_text["theme_override_colors/default_color"] = Color(0.0,0.0,0.0,1.0)
		arrow.frame_coords.x = 1
	else:
		$textbox_text["theme_override_colors/default_color"] = Color(1.0,1.0,1.0,1.0)
		arrow.frame_coords.x = 0
	textbox_content.visible_characters=0
	text_background.frame_coords.x = background
	#PLAY TEXTBOX SOUND
	change_box_sound.play()
	#TYPING SOUND IS ON AUTO-PLAY BUT MUTE, THIS DOES THE FADE-IN
	create_tween().tween_property(dialogue_typing_sound,"volume_db",TYPING_SOUND_VOLUME,TYPING_SOUND_FADE_IN_TIME)
	#CHECKS WHETHER TO START WITH SLOW (if the text starts with a special character) OR FAST TYPING SPEED
	check_character()
	#MAKES WAIT TIME SMALL SO TEXT APPEARS AS SOON AS TEXTBOX STARTS
	text_timer.set_wait_time(text_timer.wait_time/5)
	#STARTS THE TIMER
	text_timer.start()
	if Global.gen<=2:
		change_box_sound.volume_db=-80
		dialogue_typing_sound.volume_db=-80


func _process(_delta):
	#WAITS UNTIL HALF THE TIME HAS BEEN COMPLETED TO SHOW THE TEXTBOX BACKGROUND.
	if get_tree().paused:
		dialogue_typing_sound.set_stream_paused(true)
	else:
		dialogue_typing_sound.set_stream_paused(false)
		
	if text_timer.get_time_left()<text_timer.wait_time/2.0:
		text_background.visible=true
		
	#STARTS SHOWING TEXT IMMEDIATELY IF NO TEXT HAS APPEARED YET

		if textbox_content.visible_characters==0 && text_timer.get_time_left()<text_timer.wait_time/2.0:
			textbox_content.visible_characters=1

			
	#CHECKS IF TEXT HAS ENDED, IF IT DID, PLAY CLOSE SOUND AND DELETE TEXTBOX
	if textbox>text.size()-1:
		textbox = 0
		if Global.gen>2:
			get_node("../../dialogue_close").playing=true
		queue_free()
		
	#SETS THE TEXT OF THE TEXTBOX
	textbox_content.text = text[textbox]
	
	#IF DIDN'T FINISH TYPING EVERYTHING, KEEP TYPING, IF IT DID, STOP PLAYING TYPING SOUND
	if textbox_content.visible_ratio != 1.0:
		textbox_content.visible_characters = chars
	else:
		if arrow_time.is_stopped():
			arrow_time.start()
		dialogue_typing_sound.playing = false
	
	#ALLOWS YOU TO SKIP TEXTBOX WHEN YOU PRESS ACTION, SHOWS FULL TEST AND DISPLAYS "NEXT" ARROW.
	if Input.is_action_just_pressed("pressed_action") && textbox_stage==0:
		text_timer.stop()
		textbox_content.visible_ratio = 1.0
		textbox_stage=1
		arrow_time.start()
	
	if Global.gen<=2:
		textbox_content.visible_ratio = 1.0
		textbox_stage=2
	
	#IF FINISHED TYPING, AND YOU ARE NOT PRESSING ANY BUTTON, ALLOW YOU TO PROCCEED BY PRESSING X
	if textbox_content.visible_ratio==1.0 && !Input.is_action_pressed("pressed_action"):
		textbox_stage=2
		
		
		
	#IF YOU SKIPPED TEXTBOX, ALLOWS YOU TO PROCEED ONLY AFTER YOU STOP HOLDING ACTION.
	if !get_tree().paused:
		if Input.is_action_just_released("pressed_action") && textbox_stage==1:
			textbox_stage=2
			arrow_time.start()
			
		#GOES TO NEXT TEXTBOX, IF THERE'S ANY
		if Input.is_action_just_pressed("pressed_action") && textbox_stage==2:
			textbox_stage=0
			textbox+=1
			chars = 0
			arrow_time.stop()
			arrow.visible = false
			textbox_content.visible_ratio = 0.0
			if textbox<text.size():
				change_box_sound.play()
			text_timer.start()
		
	
	#STARTS TO DISPLAY ARROW AS SOON AS TEXT IS OVER
	if arrow_time.time_left==arrow_time.wait_time:
		arrow.visible = true
		
		
func check_character():
	text_timer.stop()
	#CHECKS IF CHARACATER IS NORMAL OR SPECIAL CHARACTER, WHICH IS TYPED SLOWER ON PETSCOP
	if textbox_content.visible_characters!=Global.strip_bbcode(textbox_content.text).length():
		if slowchars.find(Global.strip_bbcode(textbox_content.text)[textbox_content.visible_characters])==-1:
			text_timer.wait_time = DEFAULT_WAIT
			if !dialogue_typing_sound.playing && Global.gen>2:
				dialogue_typing_sound.playing=true
				create_tween().tween_property(dialogue_typing_sound,"volume_db",TYPING_SOUND_VOLUME,TYPING_SOUND_FADE_IN_TIME)
		else:
			text_timer.wait_time = PUNCTUATION_WAIT
			dialogue_typing_sound.playing=false
			dialogue_typing_sound.volume_db=-80.
#TEXT TIMER STUFF
func _on_textbox_timer_timeout():
	if textbox<=text.size()-1 && !get_tree().paused:
		if chars<text[textbox].length():
			chars+=1
			check_character()
			text_timer.start()
		

#ARROW TIMER STUFF
func _on_arrow_timer_timeout():
	arrow.visible = !arrow.visible
