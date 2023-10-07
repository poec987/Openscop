extends Node3D
const TILE_SIZE = 29
func _process(_delta):
	position = Vector3(round(get_node("../../player").position.x/TILE_SIZE)*TILE_SIZE,0,round(get_node("../../player").position.z/TILE_SIZE)*TILE_SIZE)
