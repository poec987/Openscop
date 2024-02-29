extends Node2D
var texture_data: CompressedTexture2D = null
var texture_image = null
func _process(_delta):
	if visible:
		if get_tree().get_root().get_child(4).find_child("level_root").find_child("visual_mesh"):
			#$Texture.set_texture(get_tree().get_root().get_child(4).find_child("level_root").find_child("visual_mesh").get_child(0).get_material_override().get_shader_parameter("albedo_tex"))
			texture_data = get_tree().get_root().get_child(4).find_child("level_root").find_child("visual_mesh").get_child(0).get_material_override().get_shader_parameter("albedo_tex")
			texture_image = texture_data.get_image()
			$Texture.set_texture(ImageTexture.create_from_image(texture_image))
		$pencil.position=Vector2(round(clamp($pencil.position.x,32,288)),round(clamp($pencil.position.y,0,240)))
		if Input.is_action_pressed("pressed_start"):
			$pencil.position=Vector2i(32,230)
		$pencil.position.y+= int(Input.is_action_pressed("pressed_down"))-int(Input.is_action_pressed("pressed_up"))
		$pencil.position.x+= int(Input.is_action_pressed("pressed_right"))-int(Input.is_action_pressed("pressed_left"))
		if Input.is_action_pressed("pressed_action"):
			if $pencil.position.x<texture_image.get_width() && $pencil.position.y<texture_image.get_height():
				texture_image.set_pixel($pencil.position.x-32, $pencil.position.y, Color.html("#FFCEE5"))
				$Texture.set_texture(ImageTexture.create_from_image(texture_image))
