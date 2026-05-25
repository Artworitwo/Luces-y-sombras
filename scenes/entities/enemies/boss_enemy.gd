extends CharacterBody2D

@export var speed: int = 200
@export var speed_horizontal: int 
@export var damage: int
@onready var animated_sprite = $AnimatedSprite2D
@onready var animated_attack= $Special/AnimatedSpecial
@onready var timer = $Timer
@onready var health_bar = $HealthBar # Asumiendo que tienes una ProgressBar como hijo
@onready var special = $Special
@onready var atackBox = $Hurtbox/CollisionShape2D

var health 
var health_max: float = 4.0
var current_floor = 3
var attack_count = 0
var is_invulnerable = true

const JUMP_VELOCITY = -935.0

enum STATE { SPAWN, IDLE, JUMP, DOWN, ATTACK, WEAKNESS, DEATH }
var current_state = STATE.SPAWN

func _ready() -> void:
	if !multiplayer.is_server(): return

	# Forzamos que empiece en SPAWN y reproduzca la animación
	current_state = STATE.SPAWN
	animated_sprite.play("spawn")
	timer.start()
	special.disabled = true
	health = health_max
	health_bar.value = (health / health_max) * 100
	_iniciar_siguiente_decision() 
	print("Diva inicializada y pensando...")
	animated_attack.visible = false

func _physics_process(delta: float) -> void:
	# Soporte para multijugador
	if !multiplayer.is_server(): return
	
	if is_queued_for_deletion() or current_state == STATE.DEATH:
		return
	
	# Gravedad
	if not is_on_floor():
		velocity.y += 2000 * delta

	# Verificación de Muerte
	if health <= 0 and current_state != STATE.DEATH:
		current_state = STATE.DEATH 

	# Lógica de estados
	match current_state:
		STATE.SPAWN:
			velocity.x = 0
			if animated_sprite.animation != "spawn":
				animated_sprite.play("spawn")
			is_invulnerable = true

		STATE.IDLE:
			velocity.x = 0
			if animated_sprite.animation != "idle":
				animated_sprite.play("idle")
			is_invulnerable = true

		STATE.JUMP:
			if is_on_floor():
				velocity.y = JUMP_VELOCITY
			if animated_sprite.animation != "jump":
				animated_sprite.play("jump")
			is_invulnerable = true

		STATE.DOWN:
			if is_on_floor():
				position.y += 5 # Pequeño empujón para bajar plataformas "One-way"
			is_invulnerable = true

		STATE.ATTACK:
			if animated_sprite.animation != "attack":
				animated_sprite.play("attack")
			animated_attack.visible = true
			animated_attack.play("default")
			special.disabled = false
			await get_tree().create_timer(2.0).timeout
			special.disabled = true
			animated_attack.visible = false
			current_state = STATE.WEAKNESS
			timer.start(3.0)
			is_invulnerable = true
			

		STATE.WEAKNESS: 
			damage = 0
			atackBox.disabled = true
			velocity.x = 0
			is_invulnerable = false # AQUÍ SÍ LE DUELE
			if animated_sprite.animation != "weakness":
				animated_sprite.play("weakness")
				# Parpadeo visual de debilidad (Azul o Blanco)
				#animated_sprite.modulate = Color(0.5, 0.5, 2.0) 

		STATE.DEATH:
			velocity = Vector2.ZERO
			if animated_sprite.animation != "death":
				animated_sprite.play("death")
				# Avisar al nivel
			if get_parent().get_parent().has_method("record_death"):
				get_parent().get_parent().record_death()
				get_parent().get_parent().boss_defeated()
			queue_free()

	move_and_slide()

# --- RECIBIR DAÑO ---
func receive_damage () -> void:
	if is_invulnerable:
		#Aquí podrías llamar a la función de daño del JUGADOR
		PLAYER.flash_damage()
		PLAYER.health -= 2 
		print("Es inmune")
		return
	print("recibio daño")
	health -= PLAYER.damage
	if health_bar:
		health_bar.value = (health / health_max) * 100
	
	# Feedback visual de daño (Flash rojo)
	animated_sprite.modulate = Color(10, 1, 1) # Rojo intenso
	await get_tree().create_timer(0.1).timeout
	if current_state == STATE.WEAKNESS:
		animated_sprite.modulate = Color(0.5, 0.5, 2.0) # Vuelve a color debilidad
	else:
		animated_sprite.modulate = Color(1, 1, 1) # Vuelve a normal

# --- SEÑALES DE ANIMACIÓN ---
func _on_animated_sprite_2d_animation_finished() -> void:
	if (animated_sprite.animation == "spawn"):
		current_state = STATE.IDLE
		# Liberar a los jugadores para que empiece la pelea
		get_tree().call_group("players", "cambiar_estado", 0) # 0 suele ser STATE.IDLE
		_iniciar_siguiente_decision()
	match current_state:
		STATE.SPAWN:
			current_state = STATE.IDLE
			_iniciar_siguiente_decision()
		STATE.JUMP, STATE.DOWN:
			current_state = STATE.ATTACK
		STATE.ATTACK:
			attack_count += 1
			if attack_count >= 3:
				current_state = STATE.WEAKNESS
				timer.start(3.0) # Duración de la debilidad
				
			else:
				_iniciar_siguiente_decision()
		STATE.DEATH:
			queue_free() 

# --- DECISIONES ---
func _on_timer_timeout() -> void:
	if current_state == STATE.WEAKNESS:
		# Se acabó el tiempo de debilidad
		atackBox.disabled = false
		attack_count = 0
		animated_sprite.modulate = Color(1, 1, 1)
		current_state = STATE.IDLE
		_iniciar_siguiente_decision()
		return
	
	var decision = randi_range(0, 100)
	print("Tomando decision de verdad")
	if decision < 30 and current_floor < 4:
		current_floor += 1
		current_state = STATE.JUMP
	elif decision < 60 and current_floor > 1:
		current_floor -= 1
		current_state = STATE.DOWN
	else:
		current_state = STATE.ATTACK

func _iniciar_siguiente_decision():
	damage = 2
	timer.wait_time = randf_range(1.0, 2.5)
	timer.start()

func _on_hurtbox_area_entered(body: Area2D) -> void:
	if body.name == "HitBoxAttack":
		if current_state == STATE.WEAKNESS:
			body.receive_damage(PLAYER.damage)
		else:
			print("Es inmune en esta estado")
			

			
