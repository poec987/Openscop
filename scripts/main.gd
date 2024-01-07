extends Node3D
const PORT = 7777
@onready var test_level = "res://scenes/test.tscn"
@onready var level_holder = $level
# Called when the node enters the scene tree for the first time.
func _ready():
	load_level()

func _unhandled_input(event):
	if event.is_action("host"): start_host()
	
func join_server():
	var t_peer = ENetMultiplayerPeer.new()
	t_peer.create_client("127.0.0.1", PORT) # <---------------- Replace later
	if t_peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed To Create Client :(")
		return
	multiplayer.multiplayer_peer = t_peer

func start_host():
	print_debug("Starting Server...")
	
	var t_peer = ENetMultiplayerPeer.new()
	t_peer.create_server(PORT)
	if t_peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed To Create Server :(")
		return
	multiplayer.multiplayer_peer = t_peer

func load_level():
	var t_level = load(test_level).instantiate()
	level_holder.add_child(t_level)
	
