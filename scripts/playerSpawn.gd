extends MultiplayerSpawner

@export var network_player: PackedScene

func _ready() -> void:
	#multiplayer.peer_connected.connect(_on_peer_connected)
	CREATE.skin_recibida.connect(spawn_player)
	
	if multiplayer.is_server():
		spawn_player(multiplayer.get_unique_id())
		
func _on_peer_connected(id: int) -> void:
	if !multiplayer.is_server(): return
	spawn_player(id)
	#_notificar_jugadores_existentes(id)

func spawn_player(id:int)-> void:
	if !multiplayer.is_server(): return
	
	var player: Node = network_player.instantiate()
	player.name = str(id)
	player.set_multiplayer_authority(id)
	player.cuerpo_actual = CREATE.skins_por_jugador.get(id, 0)
	get_node(spawn_path).call_deferred("add_child", player)

	
