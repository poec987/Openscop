extends Node2D

var screenshotted = false
@export var can_unpause = true
const SCREEN_ANIM_TIME = 1.5
	
func get_screen():
	var viewport_feed: Viewport = get_viewport()
	var screen_texture: Texture2D = viewport_feed.get_texture()
	var screen_image: Image = screen_texture.get_image()
	#var static_image: ImageTexture = ImageTexture.create_from_image(screen_image)
	var screen: Texture2D = ImageTexture.create_from_image(screen_image)
	return screen
func _process(_delta):
	if Global.game_paused:
		if !screenshotted:
			$screen_sprite.set_texture(get_screen())
			#$screen_sprite.update(screen)
			create_tween().tween_property($screen_sprite,"scale",Vector2(0.48,0.48),SCREEN_ANIM_TIME).set_trans(Tween.TRANS_LINEAR)
			screenshotted = true
		
