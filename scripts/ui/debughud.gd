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
		$PlayerPos.text=str("Position: X:",player.position.x," Y:",player.position.y," Z:",player.position.z,"\nDIR:",player.animation_direction)
		$PlayerVel.text=str("Velocity: X:",player.velocity.x," Y:",player.velocity.y," Z:",player.velocity.z)
	else: #IF THERE IS NO PLAYER THIS CODE IS RAN
		$PlayerPos.text="NO PLAYER FOUND!"
		$PlayerVel.text=""
