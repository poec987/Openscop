extends Node

func change_scene(scene):
	if get_child_count() > 0:
		get_node("PSXLayer/NTSC/NTSC_viewport/Dither/dither_view").get_child(0).queue_free()
	var new_world = load(scene)
	var new_child = new_world.instantiate()
	get_node("PSXLayer/NTSC/NTSC_viewport/Dither/dither_view").add_child(new_child)
	
func _process(_delta):
	if Input.is_action_just_pressed("ntsc"):
		RenderingServer.global_shader_parameter_set("ntsc_enable", !RenderingServer.global_shader_parameter_get("ntsc_enable"))
	if Input.is_action_just_pressed("posterize"):
		RenderingServer.global_shader_parameter_set("posterize", !RenderingServer.global_shader_parameter_get("posterize"))
	if Input.is_action_just_pressed("dither"):
		RenderingServer.global_shader_parameter_set("dither_banding", !RenderingServer.global_shader_parameter_get("dither_banding"))
