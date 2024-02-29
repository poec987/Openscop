extends Control

#DECLARING VARIABLES
@onready var player
@onready var isplayer = false #THIS VALUE CHECKS IF THERES A PLAYER

#FUNCTIONS
func _ready():
	#CHECK IF THERES A PLAYER NODE IN THE SCENE
	if get_tree().get_first_node_in_group("Player"): #PLAYER NODE FOUND
		player = get_tree().get_first_node_in_group("Player")
		isplayer = true
	else: #NO PLAYER NODE FOUND
		isplayer = false

func _process(_delta):
	if isplayer: #IF THERE IS A PLAYER THIS CODE IS RAN
		$PlayerPos.text=str("Position: X:",snapped(player.position.x,0.0001)," Y:",snapped(player.position.y,0.0001)," Z:",snapped(player.position.z,0.0001),"\nDIR:",player.animation_direction)
		$PlayerVel.text=str("Velocity: X:",snapped(player.velocity.x,0.00001)," Y:",snapped(player.velocity.y,0.00001)," Z:",snapped(player.velocity.z,0.00001))
	else: #IF THERE IS NO PLAYER THIS CODE IS RAN
		$PlayerPos.text="NO PLAYER FOUND!"
		$PlayerVel.text=" "
