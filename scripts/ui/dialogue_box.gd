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

#AMOUNT OF CHARS ON DISPLAY, PAGE OF TEXTBOX.
var chars = 0
var textbox = 0

#CHARACTERS THAT MAKE TYPEWRITER SLOWER
var slowchars="!.?,;"

#CHECK IF IS READY TO SKIP.
var textbox_stage = 0

func _ready():
	
	#SETS UP THE TEXTBOX BACKGROUND
	if background==0:
		$textbox_text["theme_override_colors/default_color"] = Color(0.0,0.0,0.0,1.0)
		$textbox_arrow.frame_coords.x = 1
	else:
		$textbox_text["theme_override_colors/default_color"] = Color(1.0,1.0,1.0,1.0)
		$textbox_arrow.frame_coords.x = 0
	$textbox_text.visible_characters=0
	$textbox_background.frame_coords.x = background
	#PLAY TEXTBOX SOUND
	$dialogue_change.play()
	#TYPING SOUND IS ON AUTO-PLAY BUT MUTE, THIS DOES THE FADE-IN
	create_tween().tween_property($dialogue_typing,"volume_db",TYPING_SOUND_VOLUME,TYPING_SOUND_FADE_IN_TIME)
	#CHECKS WHETHER TO START WITH SLOW (if the text starts with a special character) OR FAST TYPING SPEED
	check_character()
	#MAKES WAIT TIME SMALL SO TEXT APPEARS AS SOON AS TEXTBOX STARTS
	$textbox_timer.set_wait_time($textbox_timer.wait_time/5)
	#STARTS THE TIMER
	$textbox_timer.start()
	
	

func _process(_delta):
	#WAITS UNTIL HALF THE TIME HAS BEEN COMPLETED TO SHOW THE TEXTBOX BACKGROUND.
	if get_tree().paused:
		$dialogue_typing.set_stream_paused(true)
	else:
		$dialogue_typing.set_stream_paused(false)
		
	if $textbox_timer.get_time_left()<$textbox_timer.wait_time/2.0:
		$textbox_background.visible=true
		
	#STARTS SHOWING TEXT IMMEDIATELY IF NO TEXT HAS APPEARED YET
	if $textbox_text.visible_characters==0 && $textbox_timer.get_time_left()<$textbox_timer.wait_time/2.0:
		$textbox_text.visible_characters=1
	
	#CHECKS IF TEXT HAS ENDED, IF IT DID, PLAY CLOSE SOUND AND DELETE TEXTBOX
	if textbox>text.size()-1:
		textbox = 0
		get_node("../../dialogue_close").playing=true
		queue_free()
		
	#SETS THE TEXT OF THE TEXTBOX
	$textbox_text.text = text[textbox]
	
	#IF DIDN'T FINISH TYPING EVERYTHING, KEEP TYPING, IF IT DID, STOP PLAYING TYPING SOUND
	if $textbox_text.visible_ratio != 1.0:
		$textbox_text.visible_characters = chars
	else:
		if $arrow_timer.is_stopped():
			$arrow_timer.start()
		$dialogue_typing.playing = false
	
	#ALLOWS YOU TO SKIP TEXTBOX WHEN YOU PRESS ACTION, SHOWS FULL TEST AND DISPLAYS "NEXT" ARROW.
	if Input.is_action_just_pressed("pressed_action") && textbox_stage==0:
		$textbox_timer.stop()
		$textbox_text.visible_ratio = 1.0
		textbox_stage=1
		$arrow_timer.start()
	
	#IF FINISHED TYPING, AND YOU ARE NOT PRESSING ANY BUTTON, ALLOW YOU TO PROCCEED BY PRESSING X
	if $textbox_text.visible_ratio==1.0 && !Input.is_action_pressed("pressed_action"):
		textbox_stage=2
		
		
		
	#IF YOU SKIPPED TEXTBOX, ALLOWS YOU TO PROCEED ONLY AFTER YOU STOP HOLDING ACTION.
	if !get_tree().paused:
		if Input.is_action_just_released("pressed_action") && textbox_stage==1:
			textbox_stage=2
			$arrow_timer.start()
			
		#GOES TO NEXT TEXTBOX, IF THERE'S ANY
		if Input.is_action_just_pressed("pressed_action") && textbox_stage==2:
			textbox_stage=0
			textbox+=1
			chars = 0
			$arrow_timer.stop()
			$textbox_arrow.visible = false
			$textbox_text.visible_ratio = 0.0
			if textbox<text.size():
				$dialogue_change.play()
			$textbox_timer.start()
		
	
	#STARTS TO DISPLAY ARROW AS SOON AS TEXT IS OVER
	if $arrow_timer.time_left==$arrow_timer.wait_time:
		$textbox_arrow.visible = true
		
		
func check_character():
	#CHECKS IF CHARACATER IS NORMAL OR SPECIAL CHARACTER, WHICH IS TYPED SLOWER ON PETSCOP
	if slowchars.find($textbox_text.text[$textbox_text.visible_characters])==-1:
		$textbox_timer.wait_time = DEFAULT_WAIT
		if !$dialogue_typing.playing:
			$dialogue_typing.playing=true
			create_tween().tween_property($dialogue_typing,"volume_db",TYPING_SOUND_VOLUME,TYPING_SOUND_FADE_IN_TIME)
	else:
		$textbox_timer.wait_time = PUNCTUATION_WAIT
		$dialogue_typing.playing=false
		$dialogue_typing.volume_db=-80.

#TEXT TIMER STUFF
func _on_textbox_timer_timeout():
	if textbox<=text.size()-1 && !get_tree().paused:
		if chars<text[textbox].length():
			chars+=1
			check_character()
			$textbox_timer.start()
		

#ARROW TIMER STUFF
func _on_arrow_timer_timeout():
	$textbox_arrow.visible = !$textbox_arrow.visible
