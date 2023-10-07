extends Node3D


# Called when the node enters the scene tree for the first time.
const TILE_SIZE = 29
var current_position = [0,0]

func _process(_delta):
	position = Vector3(round(get_node("../../player").position.x/TILE_SIZE)*TILE_SIZE,0,round(get_node("../../player").position.z/TILE_SIZE)*TILE_SIZE)


