extends MultiplayerSpawner

@export var listEnemy:PackedScene


func trigger_boss_spawn():
	if !multiplayer.is_server(): return
	
	if listEnemy == null:
		print("¡No hay enemigo en el Inspector!")
	var boss_instance = listEnemy.instantiate()
	# Posición fija de Jefe
	boss_instance.position = Vector2(960, 440) 
	boss_instance.name = "Boss_Diva"

	# Usamos call_deferred para evitar errores de jerarquía
	get_node(spawn_path).call_deferred("add_child", boss_instance)
