extends Node2D

@export var listEnemy:PackedScene
@export var minTimeSpawn:int
@export var maxTimeSpawn:int
@onready var timer = $Timer

var random = RandomNumberGenerator.new()
 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	random.randomize()
	timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_timer_timeout() -> void:
	if listEnemy == null:
		print("¡No hay enemigo en el Inspector!")
	var enemy_instance = listEnemy.instantiate()
	enemy_instance.position = Vector2(random.randi_range(400,1500), random.randi_range(30, 800))
	get_parent().add_child(enemy_instance)
	
	_next_cooldown()

func _next_cooldown():
	print("Spawneando más enemigos")
	timer.wait_time = randf_range(minTimeSpawn, maxTimeSpawn)
	timer.start()
