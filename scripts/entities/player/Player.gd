extends CharacterBody2D

"""
Aclaración 1: Cada CollisionObject a la derecha en el inspector tiene
nivel de colision, implica que los que esten en la mismo nivel
existen en el mismo universo, los layer es para que sean tangibles
y los mask es para que pueda ver otros de su nivel
Player es 1
Enemies es 2
y World (El entorno) es 3

Aclaración 2: Ahorita descubrí al función de grupos y sirve para 
agrupar nodos en un familia, por ahora no hace mucho, solo estan
los dos player, pero serviria para llamar a los nodos que esten 
dentro de ese grupo y llamar a la función en especifico, servirá
mucho para cuando hagamos los enemigos

Aclaración 3: Por ahora seguimos todo el formato en inglés, nombres
de variables, carpetas, escenas, scripts, lo único que no en ingles
son los comentarios, eso si en español y por favor colocar el 
motor Godot en ingles, para cuando se diga algo se entienda de donde es
"""

# Variables de movimiento, fueron creadas desde el input map de 
# project settings como buena practica de tener tus teclas asignadas
# asignadas a variables que uno creaste, para poder tener una misma 
# tecla a varias variables

# Creamos las variables como propiedad del Jugador y se llenan con 
# nuestros propio input map
@export
var right_input:String
@export
var left_input:String
@export
var jump_input:String
@export
var down_input:String

# Variables de movimiento
const SPEED = 300.0
const JUMP_VELOCITY = -660.0
var direction = 1

# Se ejecuta acorde con la cantidad de fotogramas que soporte tu 
# computador, desde 1 hasta 400. útil para cosas de renderizado o gráfico
func _process(delta: float) -> void:
	
	# Método de prueba para detectar un click del usuario
	if Input.is_action_just_pressed("clickLeft"):
		print("click")
	
	pass

# Se ejecuta 60 veces por segundo, no sobrecargarlo
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
			$HitBoxAttack.position.x = 0
		else:
			#Cambia la orientación del sprite y de la HitBoxAtaque
			$AnimatedSprite2D.flip_h = true
			$HitBoxAttack.position.x = -108

	# Manejo del salto
	if Input.is_action_just_pressed(jump_input) and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Manejo para bajar plataforma
	if Input.is_action_just_pressed(down_input) and is_on_floor():
		position.y +=1
		
	# Cambiar la dirección de movimiento y la de HitBoxAtaque 
	if Input.is_action_just_pressed(left_input):
		direction = -1
		# Voltea el dibujo (si tu nodo se llama Sprite2D)
		$AnimatedSprite2D.flip_h = true 
		# Mueve la hitbox a la izquierda
		$HitBoxAttack.position.x = -108
		
	elif Input.is_action_just_pressed(right_input):
		direction = 1
		$AnimatedSprite2D.flip_h = false 
		# Mueve la hitbox a la derecha
		$HitBoxAttack.position.x = 0
	# El movimiento automático como tal
	velocity.x = direction * SPEED
	
	move_and_slide()

# Una señal es una funcion que a diferencia de proccess (que se activa
# dependiendo de los fotograms de tu pc) y proccess_physic (se activa
# 60 veces por segundo), esta se activa cuando hace lo que dice 
# estipula la funcion

# Es una señal de las pestaña de Signals a la derecha del editor
# que detecta las colisiones de mi HitBoxAtaque con su entorno,
# útil para cuando querramos definir como abatir a los enemigos
func _on_hit_box_attack_body_entered(body: Node2D) -> void:
	print("colision con: ", body)
	# Preguntamos si el cuerpo con el que chocamos tiene la "camiseta" de Enemigo
	if body.is_in_group("Enemigo"):
		print("¡Le pegaste a un Bully!")
		# Aquí luego le dirás al enemigo que se desactive o se purifique
		# body.purificar()
		
		
