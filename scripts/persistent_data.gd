extends Node

#GENERAL GAME MANAGEMENT
var fullscreen = false
var sheets = DirAccess.open("user://sheets")

func _process(_delta):
	if Input.is_action_just_pressed("screenshot"):
		var viewport_feed: Viewport =  get_tree().root.get_viewport()
		var screen_texture: Texture2D = viewport_feed.get_texture()
		var screen_image: Image = screen_texture.get_image()
		screen_image.save_png("user://screenshots/screenshot"+str((DirAccess.open("user://screenshots").get_files()).size())+".png")
	#CHECKS INPUTS FOR SHEET FOLDER HOTKEY AND FULLSCREEN BUTTON
	if Input.is_action_just_pressed("open_sheet_folder"):
		OS.shell_show_in_file_manager(ProjectSettings.globalize_path("user://sheets"),true)

	if Input.is_action_just_pressed("fullscreen"):
		fullscreen = !fullscreen
		DisplayServer.window_set_mode((DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED))
