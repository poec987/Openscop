extends Node3D
@onready var player = get_node("../player/player")
func _process(_delta):
	position.x = player.position.x
	position.z = player.position.z
