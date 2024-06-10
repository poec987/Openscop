extends Node

#GENERAL GAME MANAGEMENT
var fullscreen = false
var sheets = DirAccess.open("user://sheets")



#CODES
var nifty_code = ["pressed_l2","pressed_square","pressed_r1","pressed_triangle","pressed_r2","pressed_up","pressed_r2","pressed_circle","pressed_r2","pressed_circle"]
var input_counter = 0
var last_input = ""

#I AM A FUCKING GENIUS
	#var input_sim = InputEventAction.new()
	#InputMap.action_erase_events("pressed_left")
	#input_sim.set_action("pressed_left")
	#input_sim.set_pressed(true)
	#Input.parse_input_event(input_sim)
	
func _process(_delta):
	if Input.is_action_just_pressed("pressed_l2") || Input.is_action_just_pressed("pressed_l1") || Input.is_action_just_pressed("pressed_r2") || Input.is_action_just_pressed("pressed_r1") || Input.is_action_just_pressed("pressed_up") || Input.is_action_just_pressed("pressed_down") || Input.is_action_just_pressed("pressed_left") || Input.is_action_just_pressed("pressed_right") || Input.is_action_just_pressed("pressed_start") || Input.is_action_just_pressed("pressed_select") || Input.is_action_just_pressed("pressed_action") || Input.is_action_just_pressed("pressed_triangle") || Input.is_action_just_pressed("pressed_square") || Input.is_action_just_pressed("pressed_circle"):
		if Input.is_action_just_pressed(nifty_code[input_counter]):
			if input_counter<9:
				print(nifty_code[input_counter])
				input_counter+=1
			else:
				if Global.room_name!="garalina":
					Global.nifty()
		else:
			input_counter=0

	if Input.is_action_just_pressed("screenshot"):
		var viewport_feed: Viewport =  get_tree().root.get_viewport()
		var screen_texture: Texture2D = viewport_feed.get_texture()
		var screen_image: Image = screen_texture.get_image()
		screen_image.save_png("user://screenshots/screenshot"+str((DirAccess.open("user://screenshots").get_files()).size())+".png")
	#CHECKS INPUTS FOR SHEET FOLDER HOTKEY AND FULLSCREEN BUTTON
	if Input.is_action_just_pressed("open_sheet_folder"):
		OS.shell_show_in_file_manager(ProjectSettings.globalize_path("user://sheets"),true)
	if Input.is_action_just_pressed("screenshot_folder"):
		OS.shell_show_in_file_manager(ProjectSettings.globalize_path("user://screenshots"),true)

	if Input.is_action_just_pressed("fullscreen"):
		fullscreen = !fullscreen
		DisplayServer.window_set_mode((DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED))
		
	if Input.is_action_just_pressed("console"):
		Console.visible = !Console.visible
