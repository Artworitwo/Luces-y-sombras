extends MultiplayerSpawner

@export var listEnemy:PackedScene


func trigger_boss_spawn(health_bonus: int):
	if !multiplayer.is_server(): return
	
	if listEnemy == null:
		print("¡No hay enemigo en el Inspector!")
	var boss_instance = listEnemy.instantiate()
	boss_instance.health_max += health_bonus
	boss_instance.position = Vector2(960, 440) 
	boss_instance.name = "Boss_Diva"

	# Usamos call_deferred para evitar errores de jerarquía
	get_node(spawn_path).call_deferred("add_child", boss_instance)
