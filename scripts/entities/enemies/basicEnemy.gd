extends CharacterBody2D


@export var speed = 100
@export var direction:int
@export var healt:int
@onready var animated_sprite = $AnimatedSprite2D
@onready var timer = $Timer 


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
	#if !multiplayer.is_server(): return
	if not is_on_floor():
		velocity.y += 2000 * delta
		
	if healt <= 0 and current_state != STATE.DEATH:
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
			if animated_sprite.animation != "death":
				animated_sprite.play("death")
				get_parent().get_parent().record_death()
				await animated_sprite.animation_finished
				get_parent().remove_child(self)
		
	if is_on_wall():
		direction = get_wall_normal().x
			
	move_and_slide()
		

func receive_damage() -> void:
	healt =- PLAYER.damage

func _on_animated_sprite_2d_animation_finished() -> void:
	print("¡La animación terminó! Era la de: ", animated_sprite.animation)
	if (animated_sprite.animation == "spawn"):
		current_state = STATE.IDLE
	


func _on_timer_timeout() -> void:
	print("El timer se acabó inicia nuevo decision")
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
	print("Tomando siguiente decision")
	timer.wait_time = randf_range(0.5, 3.5)
	timer.start()
