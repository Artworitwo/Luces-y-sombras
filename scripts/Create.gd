extends Node

var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()

func start_server() -> void:
	
	peer.create_server(1234)
	multiplayer.multiplayer_peer = peer

func start_client() -> void:
	
	peer.create_client("localhost", 1234)
	multiplayer.multiplayer_peer = peer
