extends Node2D

var screenshotted = false
@export var can_unpause = true
var screen: Texture2D = null
const SCREEN_ANIM_TIME = 1.5

func get_screen():
	var viewport_feed: Viewport = get_viewport()
	var screen_texture: Texture2D = viewport_feed.get_texture()
	screen = ImageTexture.create_from_image(screen_texture.get_image())
#func _ready():
	#get_screen()
	#$screen_sprite.set_texture(screen)
	
func _process(_delta):
	#print()
	if Input.is_action_just_pressed("pressed_start"):
		#visible = true
		if !screenshotted:
			get_screen()
			$screen_sprite.set_texture(screen)
			#print($screen_sprite.set_texture(screen))
			screenshotted = true
			create_tween().tween_property($screen_sprite,"scale",Vector2(0.48,0.48),SCREEN_ANIM_TIME).set_trans(Tween.TRANS_LINEAR)
	#if !Global.game_paused:
		#screenshotted = false
		
