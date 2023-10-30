extends Node

func change_scene(scene):
	if get_child_count() > 0:
		get_node("PSXLayer/NTSC/NTSC_viewport/Dither/dither_view").get_child(0).queue_free()
	var new_world = load(scene)
	var new_child = new_world.instantiate()
	get_node("PSXLayer/NTSC/NTSC_viewport/Dither/dither_view").add_child(new_child)
	
func _process(_delta):
	if Input.is_action_just_pressed("ntsc"):
		get_node("PSXLayer/NTSC").get_material().set_shader_parameter("shader_enable", !get_node("PSXLayer/NTSC").get_material().get_shader_parameter("shader_enable"))
	if Input.is_action_just_pressed("dither"):
		get_node("PSXLayer/NTSC/NTSC_viewport/Dither").get_material().set_shader_parameter("dither_banding", !get_node("PSXLayer/NTSC/NTSC_viewport/Dither").get_material().get_shader_parameter("dither_banding"))
