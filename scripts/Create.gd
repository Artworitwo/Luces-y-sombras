extends Node

var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var skins_por_jugador: Dictionary = {}  # ✅ se mueve aquí
var cuerpo_actual: int = 0 

signal skin_recibida(peer_id: int)

func start_server() -> void:
	
	peer.create_server(1234)
	multiplayer.multiplayer_peer = peer
	skins_por_jugador[1] = cuerpo_actual

func start_client() -> void:
	
	peer.create_client("localhost", 1234)
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(_on_connected)
	

func _on_connected() -> void:
	_enviar_skin.rpc_id(1, cuerpo_actual)

@rpc("any_peer")
func _enviar_skin(index: int) -> void:
	var sender_id = multiplayer.get_remote_sender_id()
	skins_por_jugador[sender_id] = index
	skin_recibida.emit(sender_id)
