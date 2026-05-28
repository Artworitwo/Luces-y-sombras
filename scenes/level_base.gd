extends Node2D

@export var goal_enemies_purified:int
@onready var boss_spawner = find_child("BossSpawner") # Tu MultiplayerSpawner del jefe
@onready var door
@export var enemies_purified = 0
var passpoints = 0
var boss_health_bonus = 0
var levels_cleared = 0
var final_level = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemies_purified = 0
	door = $Door

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	# 1. En lugar de borrarlos, les bajamos toda la vida
		# Esto disparará su animación de muerte y su propio queue_free()
		
func record_death() -> void:
	if !multiplayer.is_server(): return
	enemies_purified += 1
	print("Enemigos purificados: ", enemies_purified)
	
	if (enemies_purified == goal_enemies_purified):
		PLAYER.perkpoints += 1
		passpoints += 1
		limpiar_mapa_y_spawn_boss()
		
func boss_defeated() -> void:
	if !multiplayer.is_server(): return
	print("La Diva ha sido derrotada")
	if final_level == true:
		show_win_screen.rpc()
		return 
	levels_cleared += 1
	boss_health_bonus += 2
	door.visible = true
	door.next_room = "res://visual assets/Objects/BG3-zonaSegura.png"
	door.open()

func openthedoor():
	door.open()
	
func limpiar_mapa_y_spawn_boss():
	print("¡PURGA INICIADA!")
	# Esta línea busca a TODO lo que esté en el grupo "enemies" 
	# 1. APAGAR LAS FÁBRICAS (Para que no salgan más)
	get_tree().call_group("spawners", "detener_spawner")
	# y le ordena borrarse inmediatamente.
	get_tree().call_group("enemies", "purgar_enemigo")   
	# 2. Congelar a los jugadores (A través de un grupo "players")
	get_tree().call_group("players", "entrar_en_cinematica")
	# 2. Esperamos 1.5 segundos para que terminen las animaciones
	await get_tree().create_timer(2.0).timeout
	# 3. Spawneamos a la Diva
	spawn_boss()

func spawn_boss():
	print("¡EL JEFE HA DESPERTADO!")
	# Aquí llamas a la función de spawn del script que ya tienes
	boss_spawner.trigger_boss_spawn(boss_health_bonus)
	
# Esta función se llama cuando la vida llega a cero
func check_death():
	if !multiplayer.is_server(): return
	if get_node("SandCointainer").get_node(str(multiplayer.get_unique_id())).health <= 0:
		# Enviamos la orden a todos (incluyendo clientes)
		show_game_over_screen.rpc()
		CREATE.stop_multiplayer()

@rpc("authority", "call_local", "reliable")
func show_game_over_screen():
	# Instanciamos la escena de Game Over
	var game_over = preload("res://ui/GameOver.tscn").instantiate()
	add_child(game_over)
	# Opcional: pausar el juego para que nada se mueva atrás
	get_tree().paused = true
	
@rpc("authority", "call_local", "reliable")
func show_win_screen():
	# Instanciamos la escena de Game Over
	var win = preload("res://ui/Win.tscn").instantiate()
	add_child(win)
	# Opcional: pausar el juego para que nada se mueva atrás
	get_tree().paused = true
	
@rpc("any_peer", "call_local")
func changeBack(tex_path:String):
	var tex = load(tex_path)
	$Node2D/Sprite2D.texture = tex
	var tam_objetivo = Vector2(1200, -1000)
	var tam_original = tex.get_size()
	$Node2D/Sprite2D.scale = tam_objetivo / tam_original
	if (tex_path == "res://visual assets/Objects/BG3-zonaSegura.png"):
		$SafeZone.activarAreas()
	else:
		get_tree().call_group("spawners", "activar_fabrica")
		enemies_purified = 0
		goal_enemies_purified += 3
		$SafeZone.apagarAreas()
	
func showMap(visible :bool):
	if visible == true:
		$MapTree.visible = true
	else:
		$MapTree.visible = false
	
func showTree(visible : bool):
	if visible == true:
		$PerkGraph.visible = true
	else:
		$PerkGraph.visible = false
