extends Node2D

func _process(_delta):
	if visible:
		if get_tree().find_node("visual_mesh"):
			$Texture.texture = get_tree().find_node("visual_mesh").get_child(0).get_material_override().get_shader_parameter("albedoTex")
