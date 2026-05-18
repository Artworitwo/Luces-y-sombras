extends CharacterBody2D


@export var speed: int
@export var direction:int
@export var damage: int
@onready var animated_sprite = $AnimatedSprite2D
@onready var timer = $Timer 
var health = 1


enum STATE {
	SPAWN,
	IDLE,
	MOVE,
	DEATH
}

var current_state:STATE = STATE.SPAWN

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if !multiplayer.is_server(): return
	
	if is_queued_for_deletion() or current_state == STATE.DEATH:
		return
	
	if not is_on_floor() and current_state != STATE.DEATH:
		velocity.y += 2000 * delta
		
	if health <= 0 and current_state != STATE.DEATH:
		current_state = STATE.DEATH
		
	match current_state:
		STATE.SPAWN:
			velocity.x = 0
			animated_sprite.play("spawn")
		STATE.IDLE:
			velocity.x = 0
			if animated_sprite.animation != "idle":
				animated_sprite.play("idle")
		STATE.MOVE:
			velocity.x = direction * speed
			if animated_sprite.animation != "move":
				animated_sprite.play("move")
			animated_sprite.flip_h = (direction == -1)
		STATE.DEATH:
			velocity.x = 0
			velocity.y = 1
			$CollisionShape2D.set_deferred("disabled", true)
			if animated_sprite.animation != "death":
				animated_sprite.play("death")
				get_parent().get_parent().record_death()
				await animated_sprite.animation_finished
				queue_free()
		
	if is_on_wall():
		direction = get_wall_normal().x
			
	move_and_slide()
		

func receive_damage() -> void:
	health = health - PLAYER.damage

func _on_animated_sprite_2d_animation_finished() -> void:
	#print("¡La animación terminó! Era la de: ", animated_sprite.animation)
	if (animated_sprite.animation == "spawn"):
		current_state = STATE.IDLE
	


func _on_timer_timeout() -> void:
	#print("El timer se acabó inicia nueva decision")
	var decision = randi_range(0, 100)
	
	if decision < 45:
		direction = 1
		current_state = STATE.MOVE
	elif decision < 90:
		direction = -1
		current_state = STATE.MOVE
	else:
		current_state = STATE.IDLE
	
	# IMPORTANTE: Volver a iniciar el timer con tiempo aleatorio
	_iniciar_siguiente_decision()

func _iniciar_siguiente_decision():
	#print("Tomando siguiente decision")
	timer.wait_time = randf_range(1, 3.5)
	timer.start()
	
func purgar_enemigo():
	health = 0 # Le quitamos toda la vida de golpe
	# Llamamos a la lógica que ya tienes para que cambie a estado DEATH
	# Si la lógica de muerte está en el _physics_process, esto bastará.
