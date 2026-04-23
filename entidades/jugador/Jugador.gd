extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -660.0
var direction = 1


func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	# Añadir gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Cambio de dirección automático cuando choca contra la pared	
	if is_on_wall():
		direction = direction * -1
		if direction == 1:
			#Cambia la orientación del sprite y de la HitBoxAtaque
			$AnimatedSprite2D.flip_h = false
			$HitBoxAtaque.position.x = 0
		else:
			#Cambia la orientación del sprite y de la HitBoxAtaque
			$AnimatedSprite2D.flip_h = true
			$HitBoxAtaque.position.x = -108



	# Manejo del salto
	if (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up")) and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Manejo para bajar plataforma
	if Input.is_action_just_pressed("ui_down") and is_on_floor():
		position.y +=1
		
	# Cambiar la dirección de movimiento y la de HitBoxAtaque 
	if Input.is_action_just_pressed("ui_left"):
		direction = -1
		# Voltea el dibujo (si tu nodo se llama Sprite2D)
		$AnimatedSprite2D.flip_h = true 
		# Mueve la hitbox a la izquierda
		$HitBoxAtaque.position.x = -108
		
	elif Input.is_action_just_pressed("ui_right"):
		direction = 1
		$AnimatedSprite2D.flip_h = false 
		# Mueve la hitbox a la derecha
		$HitBoxAtaque.position.x = 0
	# El movimiento automático como tal
	velocity.x = direction * SPEED
	
	move_and_slide()
