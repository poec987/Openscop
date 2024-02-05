extends Node2D

var screenshotted = false
var paused = false
@export var can_unpause = true

const SCREEN_ANIM_TIME = 1.0
var unpause_anim = false
	
func get_screen():
	var viewport_feed: Viewport =  get_tree().root.get_viewport()
	var screen_texture: Texture2D = viewport_feed.get_texture()
	var screen_image: Image = screen_texture.get_image()
	#var static_image: ImageTexture = ImageTexture.create_from_image(screen_image)
	var screen: Texture2D = ImageTexture.create_from_image(screen_image)
	return screen
func _process(_delta):
	if Global.game_paused:
		if $screen_sprite.scale.x>0.48:
			can_unpause=false
		else:
			can_unpause=true
		if !screenshotted:
			$screen_sprite.set_texture(get_screen())
			screenshotted = true
			var pauser_tween = create_tween()
			pauser_tween.tween_property($screen_sprite,"scale",Vector2(0.48,0.48),SCREEN_ANIM_TIME).set_trans(Tween.TRANS_LINEAR)
	else:
		if $screen_sprite.scale.x<1.:
			can_unpause=false
		else:
			can_unpause=true
			screenshotted=false
		if $screen_sprite.scale.x<0.48:
			var pauser_tween = create_tween()
			pauser_tween.tween_property($screen_sprite,"scale",Vector2(1.,1.),SCREEN_ANIM_TIME).set_trans(Tween.TRANS_LINEAR)
			
		
