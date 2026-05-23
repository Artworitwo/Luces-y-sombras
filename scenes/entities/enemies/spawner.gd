extends MultiplayerSpawner

@export var listEnemy:PackedScene
@export var minTimeSpawn:float
@export var maxTimeSpawn:float
@onready var timer = $Timer
var numbersfloor = [216, 442, 659, 904]

var random = RandomNumberGenerator.new()
 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	activar_fabrica()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_timer_timeout() -> void:

	if listEnemy == null:
		print("¡No hay enemigo en el Inspector!")
	var enemy_instance = listEnemy.instantiate()
	
	enemy_instance.position = Vector2(random.randi_range(400,1500), numbersfloor.pick_random())
	enemy_instance.name = "Enemy_%d" % random.randi()
	get_node(spawn_path).call_deferred("add_child", enemy_instance)
	
	_next_cooldown()

func _next_cooldown():
	#print("Spawneando más enemigos")
	timer.wait_time = randf_range(minTimeSpawn, maxTimeSpawn)
	timer.start()
	
func detener_spawner():
	timer.stop() # Apaga el reloj
	set_process(false) # Por si acaso, deja de procesar cualquier otra cosa
	print("Fábrica de enemigos cerrada.")
	
func activar_fabrica():
	if !multiplayer.is_server(): return
	random.randomize()
	timer.start()
	set_process(true)
	print("Fábrica activada.")
	
