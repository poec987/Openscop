extends Node2D

#DECLARING VARIABLES
@onready var player
@onready var isplayer = false #THIS VALUE CHECKS IF THERES A PLAYER

#FUNCTIONS
func _ready():
	get_node(".").visible=Global.debug #CHECKS IF DEBUG IS ENABLED. IF IT ISN'T, THE "DEBUGHUD" NODE'S VISIBILITY IS TURNED OFF.
	
	#CHECK IF THERES A PLAYER NODE IN THE SCENE
	if get_tree().get_first_node_in_group("Player"): #PLAYER NODE FOUND
		player = get_tree().get_first_node_in_group("Player")
		isplayer = true
	else: #NO PLAYER NODE FOUND
		isplayer = false

func _process(delta):
	if isplayer: #IF THERE IS A PLAYER THIS CODE IS RAN
		$playerpos.text=str("Position:", player.position)
		$playervel.text=str("Velocity:", player.velocity)
	else: #IF THERE IS NO PLAYER THIS CODE IS RAN
		$playerpos.text="NO PLAYER FOUND!"
		$playervel.text=" "
