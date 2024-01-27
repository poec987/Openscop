extends Node3D
#GRASS SIZE
const TILE_SIZE = 29
@onready var player = get_node("../../player")

#FOLLOWS PLAYER WHILE MAKING SNAPPED MOVEMENT, GIVING ILLUSION OF BEING INFINITE
func _process(_delta):
	position = Vector3(round(player.position.x/TILE_SIZE)*TILE_SIZE,0,round(player.position.z/TILE_SIZE)*TILE_SIZE)
