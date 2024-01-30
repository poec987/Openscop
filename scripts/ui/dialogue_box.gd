extends Node2D
const DEFAULT_WAIT = 0.5
const PUNCTUATION_WAIT = 1.0
@export var text = ["THIS IS A TEST...\n"]
var chars = 0
var textbox = 0
var slowchars="!."

func _ready():
	$textbox_text.visible_characters=0
	if slowchars.find(text[textbox][0]):
		$textbox_timer.wait_time = PUNCTUATION_WAIT
	else:
		$textbox_timer.wait_time = DEFAULT_WAIT

func _process(delta):
	var next_char = $textbox_text.visible_characters
	$textbox_text.text = text[textbox]
		
	if slowchars.find(text[textbox][next_char]):
		$textbox_timer.wait_time = PUNCTUATION_WAIT
	else:
		$textbox_timer.wait_time = DEFAULT_WAIT
		
	if chars<=text[textbox].length()-1:
		$textbox_text.visible_characters = chars
	
	
func _on_textbox_timer_timeout():
	chars+=1
