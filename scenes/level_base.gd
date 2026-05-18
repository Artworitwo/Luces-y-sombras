extends Node2D

@export var goal_enemies_purified:int
@onready var boss_spawner = find_child("BossSpawner") # Tu MultiplayerSpawner del jefe
var enemies_purified = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemies_purified = 0


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
		limpiar_mapa_y_spawn_boss()
		
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
	boss_spawner.trigger_boss_spawn()
	
# Esta función se llama cuando la vida llega a cero
func check_death():
	if not multiplayer.is_server(): return

	if PLAYER.health <= 0:
		# Enviamos la orden a todos (incluyendo clientes)
		show_game_over_screen.rpc()

@rpc("authority", "call_local", "reliable")
func show_game_over_screen():
	# Instanciamos la escena de Game Over
	var game_over = preload("res://ui/GameOver.tscn").instantiate()
	add_child(game_over)
	# Opcional: pausar el juego para que nada se mueva atrás
	get_tree().paused = true
