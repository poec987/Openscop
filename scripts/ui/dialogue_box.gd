extends Node2D
#TEXTBOX OBJECT

#TYPEWRITER SPEEDS
const DEFAULT_WAIT = 0.05
const PUNCTUATION_WAIT = 0.50

#CUSTOMIZABLE VARIABLES
@export var background = 0
@export var text = []

#AMOUNT OF CHARS ON DISPLAY, PAGE OF TEXTBOX.
var chars = 0
var textbox = 0

#CHARACTERS THAT MAKE TYPEWRITER SLOWER
var slowchars="!."

#CHECK IF IS READY TO SKIP.
var textbox_stage = 0

func _ready():
	if background==0:
		$textbox_text["theme_override_colors/default_color"] = Color(0.0,0.0,0.0,1.0)
		$textbox_arrow.frame_coords.x = 1
	else:
		$textbox_text["theme_override_colors/default_color"] = Color(1.0,1.0,1.0,1.0)
		$textbox_arrow.frame_coords.x = 0
	$textbox_text.visible_characters=0
	check_character()
	$textbox_timer.start()
		
	$textbox_background.frame_coords.x = background
	$dialogue_change.play()
	

func _process(delta):
	if textbox>text.size()-1:
		textbox = 0
		get_node("../../dialogue_close").playing=true
		queue_free()
	$textbox_text.text = text[textbox]
	if $textbox_text.visible_ratio != 1.0:
		$textbox_text.visible_characters = chars
	else:
		$dialogue_typing.playing = false
	
	if Input.is_action_just_pressed("pressed_action") && textbox_stage==0:
		$textbox_timer.stop()
		$textbox_text.visible_ratio = 1.0
		textbox_stage=1
		$arrow_timer.start()
		$textbox_arrow.visible = true
	
	if $textbox_text.visible_ratio==1.0 && !Input.is_action_pressed("pressed_action"):
		textbox_stage=2
	
	if Input.is_action_just_released("pressed_action") && textbox_stage==1:
		textbox_stage=2
	
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
		$dialogue_typing.playing = true
		
		
func check_character():
	if slowchars.find($textbox_text.text[$textbox_text.visible_characters])==-1:
		$textbox_timer.wait_time = DEFAULT_WAIT
	else:
		$textbox_timer.wait_time = PUNCTUATION_WAIT	

func _on_textbox_timer_timeout():
	if chars<text[textbox].length():
		chars+=1
		check_character()
		$textbox_timer.start()


func _on_arrow_timer_timeout():
	$textbox_arrow.visible = !$textbox_arrow.visible