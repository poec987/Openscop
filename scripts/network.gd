extends Node

var port = 9999
@rpc("any_peer")
func _send_player_information(n_ame, id, score = 0):
	if !GameManager.Players.has(id):
		GameManager.Players[id] = {
			"name" : n_ame,
			"id" : id,
			"score" : score
		}

	if multiplayer.is_server():
		for i in GameManager.Players:
			_send_player_information.rpc(GameManager.Players[i].name, i)
			
func _process(delta):
	if Input.is_action_just_pressed("host"):
		var peer = ENetMultiplayerPeer. new()
		var error = peer.create_server(port)
		if error != OK:
			print("Cannot host: " + error)
			return
		peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)

		multiplayer.set_multiplayer_peer(peer)
		print("Waiting for players")

		_send_player_information("", multiplayer.get_unique_id())
