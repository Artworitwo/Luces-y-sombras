extends CharacterBody2D
# Estados
enum STATE { IDLE, WALK, JUMP, DEATH, CINEMATIC }
var current_state = STATE.IDLE

@onready var animated_sprite = get_node("AnimatedSprite2D")
@onready var hitbox_attack = get_node("HitBoxAttack")

var is_dead = false
var health = 5
var damage = 1
var direction = 1
const SPEED = 300.0
const JUMP_VELOCITY = -935.0

func _enter_tree():
	set_multiplayer_authority(name.to_int())
	position = Vector2(500, 500)

func _ready() -> void:
	# Agregamos una pequeña espera de seguridad para el multijugador
	if animated_sprite == null:
		print("ERROR: No encontré el AnimatedSprite2D. Revisa el nombre en el árbol de nodos.")
		return
	current_state = STATE.WALK

func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority(): return
	if not is_inside_tree() or is_queued_for_deletion(): return
	
	if current_state == STATE.CINEMATIC:
		direction = 0 # No se desplaza
		velocity.x = 0

		return # Ignora el resto de inputs de movimiento

	# Gravedad universal
	if not is_on_floor():
		velocity.y += 2000 * delta

	# Lógica de muerte (Prioridad máxima)
	if health <= 0 and current_state != STATE.DEATH:
		cambiar_estado(STATE.DEATH)

	# Si está muerto, solo procesa gravedad y cae
	if current_state == STATE.DEATH:
		move_and_slide()
		return

	# PROCESAR ESTADOS
	match current_state:
		STATE.IDLE:
			procesar_movimiento()
			if velocity.x != 0: cambiar_estado(STATE.WALK)
			if Input.is_action_just_pressed("ui_up") and is_on_floor(): 
				cambiar_estado(STATE.JUMP)

		STATE.WALK:
			procesar_movimiento()
			if velocity.x == 0: cambiar_estado(STATE.IDLE)
			if Input.is_action_just_pressed("ui_up") and is_on_floor(): 
				cambiar_estado(STATE.JUMP)

		STATE.JUMP:
			procesar_movimiento()
			if is_on_floor(): cambiar_estado(STATE.WALK)

	move_and_slide()

# --- FUNCIONES DE APOYO ---

func cambiar_estado(nuevo_estado):
	current_state = nuevo_estado
	
	match current_state:
		STATE.IDLE:
			animated_sprite.play("idle") # Asegúrate de tener esta anim
		STATE.WALK:
			animated_sprite.play("walk")
		STATE.JUMP:
			velocity.y = JUMP_VELOCITY
			animated_sprite.play("jump") # Asegúrate de tener esta anim
		STATE.DEATH:
			morir_jugador()
		STATE.CINEMATIC:
			direction = 0
			animated_sprite.play("idle")

func procesar_movimiento():
	# Cambio de dirección por pared
	if is_on_wall():
		direction *= -1

	# Inputs de dirección
	if Input.is_action_just_pressed("ui_left"): direction = -1
	elif Input.is_action_just_pressed("ui_right"): direction = 1

	# Manejo de bajada de plataforma
	if Input.is_action_just_pressed("ui_down") and is_on_floor():
		position.y += 3

	# Aplicar velocidad y voltear sprite
	velocity.x = direction * SPEED
	animated_sprite.flip_h = (direction == -1)
	hitbox_attack.position.x = -80 if direction == -1 else 0

func morir_jugador():
	is_dead = true
	velocity = Vector2.ZERO
	animated_sprite.play("death")
	await animated_sprite.animation_finished
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://ui/GameOver.tscn")
	
func _on_hit_box_attack_body_entered(body: Node2D) -> void:
	#print("colision con: ", body)
	# Preguntamos si el cuerpo con el que chocamos tiene la "camiseta" de Enemigo
	if body.is_in_group("enemies"):
	#print("Entro a la funcion")
		if multiplayer.is_server():
			damage_enemy(body.get_path())
		else:
			damage_enemy.rpc_id(1, body.get_path())


# Aquí luego le dirás al enemigo que se desactive o se purifique
# body.purificar()
#esto del rpc permite que la funcion sea realizada como una
#"solicitud" al servidor/host, de forma que el cliente no esta
#metiendo manos en el server sino que solo le avisa, y el server 
#hace el resto, arribita esta la funcion con eso aplicado:
#damage_enemy.rpc_id(1, body.get_path()), donde el 1 es el host
@rpc("any_peer")
func damage_enemy(enemy_path):
	if !multiplayer.is_server():return
	var enemy = get_node(enemy_path)
	if enemy:
		enemy.receive_damage()
		
func flash_damage():
	if (animated_sprite):
		animated_sprite.modulate = Color(10, 1, 1)
		await get_tree().create_timer(0.15).timeout
		animated_sprite.modulate = Color(1, 1, 1)
		
func _on_hit_box_player_body_entered(body: Node2D) -> void:
	# 1. Seguridad para multijugador: solo el "dueño" del jugador procesa su daño
	if not is_multiplayer_authority(): return 
	if body.is_in_group("enemies"):
	# 2. Preguntamos si el objeto realmente tiene la variable damage
		if "damage" in body:
			health -= body.damage
			print("Daño recibido: ", body.damage, " | Vida restante: ", health)
			# 3. Llamamos al efecto visual
			flash_damage()
		else:
			print("Error: El enemigo ", body.name, " no tiene variable 'damage'") 
			
func entrar_en_cinematica():
	cambiar_estado(STATE.IDLE) # Lo ponemos a caminar
	# Pero no procesamos inputs, así que se queda en el sitio
	current_state = STATE.CINEMATIC
