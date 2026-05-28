extends Node

var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var skins_por_jugador: Dictionary = {}  # ✅ se mueve aquí
var cuerpo_actual: int = 0 

signal skin_recibida(peer_id: int)

var pelo_actual: int = 0
var pelos_por_jugador: Dictionary = {}
signal pelo_recibido(peer_id: int)

var jugadores_listos: Dictionary = {}

func start_server() -> void:
	
	peer.create_server(1234)
	multiplayer.multiplayer_peer = peer
	skins_por_jugador[1] = cuerpo_actual
	pelos_por_jugador[1] = pelo_actual
func start_client() -> void:
	
	peer.create_client("localhost", 1234)
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(_on_connected)
	

func _on_connected() -> void:
	_enviar_skin.rpc_id(1, cuerpo_actual)
	_enviar_pelo.rpc_id(1, pelo_actual)
	
@rpc("any_peer")
func _enviar_skin(index: int) -> void:
	var sender_id = multiplayer.get_remote_sender_id()
	skins_por_jugador[sender_id] = index
	_verificar_jugador_listo(sender_id)
	
@rpc("any_peer")
func _enviar_pelo(index: int) -> void:
	var sender_id = multiplayer.get_remote_sender_id()
	pelos_por_jugador[sender_id] = index
	_verificar_jugador_listo(sender_id)
	
func _verificar_jugador_listo(id: int) -> void:
	if jugadores_listos.has(id):
		return
	if skins_por_jugador.has(id) and pelos_por_jugador.has(id):
		jugadores_listos[id] = true
		skin_recibida.emit(id)
		
func stop_multiplayer() -> void:
	multiplayer.multiplayer_peer = null

	skins_por_jugador.clear()
