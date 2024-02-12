extends Node2D

const ANIM_SPEED = 0.25

var cursor_pos = Vector2i(0,0)
var offsets=Vector2i(1,4)
var first_row= false
var first_column= false
@onready var cursor = $keyboard_background/keyboard_inner/selector


@export var background = 0
@export var ask = true

var characters=[
	[["A"],["B"],["C"],["D"],["E"],["F"],["G"],["H"],["I"],["J"],["K"],["L"],["M"]],
	[["N"],["O"],["P"],["Q"],["R"],["S"],["T"],["U"],["V"],["W"],["X"],["Y"],["Z"]],
	[["a"],["b"],["c"],["d"],["e"],["f"],["g"],["h"],["i"],["j"],["k"],["l"],["m"]],
	[["n"],["o"],["p"],["q"],["r"],["s"],["t"],["u"],["v"],["w"],["x"],["y"],["z"]],
	[["0"],["1"],["2"],["3"],["4"],["5"],["6"],["7"],["8"],["9"],[" "],["."],["!"]],
	[["?"],[","],[";"],[":"],['"'],["'"],["("],[")"],["/"],["-"],["+"],[""],[" "]],
	]
	
func ready():
	$keyboard_background.frame_coords.x=background
	if !ask:
		$keyboard_background/keyboard_string.text=""
	
func _process(_delta):
	#if cursor_pos.x>12 || cursor_pos.x<0:
		#cursor.position.x=-16
		#cursor_pos.x=-1
		#await $wait.timeout
		#cursor_pos.x=0
	
	#if cursor.position.x<-10:
		#cursor.position.x=192
	if cursor.position.x>190:
		cursor.position.x=-16
		$wait.start()
	#if cursor.position.x<0:
	#if cursor_pos.x>12 && cursor_pos.x<0:
		#$wait.start()
	print(cursor_pos)
	if cursor_pos.x<14 && cursor_pos.x>-1:
		create_tween().tween_property(cursor,"position",Vector2(cursor_pos.x*cursor.size.x+(offsets.x*int(cursor_pos.x>0)),cursor_pos.y*cursor.size.y+(offsets.y*int(cursor_pos.y>0))),ANIM_SPEED)
	
	if cursor_pos.y>1:
		first_row=true
	else:
		first_row=false
	if cursor_pos.x>1:
		first_column=true
	else:
		first_column=false
	if $wait.time_left==0.0:
		if Input.is_action_just_pressed("pressed_up"):
			cursor_pos.y-=1
		if Input.is_action_just_pressed("pressed_down"):
			cursor_pos.y+=1
		if Input.is_action_just_pressed("pressed_left"):
			cursor_pos.x-=1
		if Input.is_action_just_pressed("pressed_right"):
			cursor_pos.x+=1
	if Input.is_action_just_pressed("pressed_action") && cursor_pos.x>0 && cursor_pos.x<12 && cursor_pos.y>0 && cursor_pos.y<5:
		if cursor_pos!=Vector2i(11,5):
			$keyboard_background/keyboard_string.text+=characters[cursor_pos.y][cursor_pos.x][0]
		else:
			if !ask:
				if $keyboard_background/keyboard_string.text.length()>0:
					$keyboard_background/keyboard_string.text=$keyboard_background/keyboard_string.text.left(-1)
			else:
				if $keyboard_background/keyboard_string.text.length()>4:
					$keyboard_background/keyboard_string.text=$keyboard_background/keyboard_string.text.left(-1)


func _on_wait_timeout():
	cursor_pos.x=0
