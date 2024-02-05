extends Node2D

var screenshotted = false
var paused = false
@export var can_unpause = true

const SCREEN_ANIM_TIME = 1.0
const BUTTON_ANIM_SPEED = 1
const MINI_SCREEN_SIZE = 0.5
var unpause_anim = false
var menus = [false,false,false,false,false]
var selected_option = 0

func get_screen():
	var viewport_feed: Viewport =  get_tree().root.get_viewport()
	var screen_texture: Texture2D = viewport_feed.get_texture()
	var screen_image: Image = screen_texture.get_image()
	#var static_image: ImageTexture = ImageTexture.create_from_image(screen_image)
	var screen: Texture2D = ImageTexture.create_from_image(screen_image)
	#screen_image.save_png("user://sheets/screen.png")
	return screen


func selection_sound(variable):
	if variable%2!=0:
		$select_up.play()
	else:
		$select_down.play()


func _process(_delta):

	if Input.is_action_just_pressed("pressed_start") && Global.control_mode==0 && get_tree().get_first_node_in_group("HUD_pausemenu").can_unpause:
		if menus.find(true)==-1:
			Global.game_paused=!Global.game_paused
	
	
	if Global.game_paused:
		get_tree().paused = true
		if $screen_sprite.scale.x>MINI_SCREEN_SIZE:
			can_unpause=false
			$screen_sprite.z_index=1
		else:
			can_unpause=true
			$screen_sprite.z_index=-1
			#$frame.visible=false
		if !screenshotted:
			var random=randi_range(0,2)
			if random==0:
				$pause_sound.play()
			elif random==1:
				$pause_sound2.play()
			elif random==2:
				$pause_sound3.play()
			$screen_sprite.set_texture(get_screen())
			$main_pausemenu/background1.visible = true
			$main_pausemenu/buttons.visible = true
			screenshotted = true
			create_tween().tween_property($screen_sprite,"scale",Vector2(MINI_SCREEN_SIZE,MINI_SCREEN_SIZE),SCREEN_ANIM_TIME).set_trans(Tween.TRANS_SINE)
	else:
		if $screen_sprite.scale.x<1.:
			can_unpause=false
		else:
			selected_option=0
			for buttons in get_node("main_pausemenu/buttons").get_children():
				if get_node("main_pausemenu/buttons").get_child(0)!=buttons:
					buttons.frame_coords.x=0
					buttons.position.x=18
				else:
					buttons.frame_coords.x=1
					buttons.position.x=28
			get_tree().paused = false
			can_unpause=true
			screenshotted=false
			$main_pausemenu/background1.visible = false
			$main_pausemenu/buttons.visible = false
			$screen_sprite.set_texture(null)
		if $screen_sprite.scale.x==MINI_SCREEN_SIZE:
			$screen_sprite.z_index=1
			create_tween().tween_property($screen_sprite,"scale",Vector2(1.,1.),SCREEN_ANIM_TIME).set_trans(Tween.TRANS_SINE)

	if can_unpause && Global.game_paused && menus.find(true)==-1:
		if Input.is_action_just_pressed("pressed_up") && selected_option!=0:
			selected_option-=1
			selection_sound(selected_option)
			
		if Input.is_action_just_pressed("pressed_down") && selected_option!=4:
			selected_option+=1
			selection_sound(selected_option)
		
		if Input.is_action_just_pressed("pressed_action"):
			menus[selected_option]=true
		
		for buttons in get_node("main_pausemenu/buttons").get_children():
			if get_node("main_pausemenu/buttons").get_child(selected_option)!=buttons:
				buttons.frame_coords.x=0
				if buttons.position.x>18:
					buttons.position.x-=BUTTON_ANIM_SPEED
			else:
				buttons.frame_coords.x=1
				if buttons.position.x<28:
					buttons.position.x+=BUTTON_ANIM_SPEED
