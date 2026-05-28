extends CharacterBody2D

enum STATE { IDLE, WALK, JUMP, DEATH, CINEMATIC }
var current_state = STATE.IDLE
var local_player

var animated_sprite: AnimatedSprite2D
var cuerpos: Array = []
var cuerpo_actual: int = 0
@onready var hitbox_attack = $HitBoxAttack
@export var is_preview: bool = false

var is_dead = false
var health = 1
var max_health: float = 5.0
var damage = 5
var direction = 1
var SPEED = 300.0
var perkpoints: int = 0
const JUMP_VELOCITY = -935.0

func _enter_tree():
	set_multiplayer_authority(name.to_int())
	position = Vector2(500, 500)

func _ready() -> void:
	await get_tree().process_frame

	for s in find_children("*", "AnimatedSprite2D", true, false):
		cuerpos.append(s as AnimatedSprite2D)

	if cuerpos.is_empty():
		push_error("No se encontraron los AnimatedSprite2D")
		return

	_aplicar_cuerpo(cuerpo_actual)

	if is_multiplayer_authority():
		local_player = self

	health = max_health
	is_dead = false

	if is_preview:
		set_physics_process(false)
		set_process(false)
		return

	current_state = STATE.IDLE
	cambiar_estado(STATE.IDLE)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += 2000 * delta

	if current_state == STATE.CINEMATIC:
		direction = 0
		velocity.x = 0
		move_and_slide()
		return

	if current_state == STATE.DEATH:
		move_and_slide()
		return

	if is_multiplayer_authority():
		if health <= 0 and current_state != STATE.DEATH:
			cambiar_estado(STATE.DEATH)

		match current_state:
			STATE.IDLE:
				procesar_movimiento()
				if velocity.x != 0: cambiar_estado(STATE.WALK)
				if Input.is_action_just_pressed("ui_up") and is_on_floor():
					velocity.y = JUMP_VELOCITY
					cambiar_estado(STATE.JUMP)
			STATE.WALK:
				procesar_movimiento()
				if velocity.x == 0: cambiar_estado(STATE.IDLE)
				if Input.is_action_just_pressed("ui_up") and is_on_floor():
					velocity.y = JUMP_VELOCITY
					cambiar_estado(STATE.JUMP)
			STATE.JUMP:
				procesar_movimiento()
				if is_on_floor(): cambiar_estado(STATE.WALK)

	move_and_slide()
	if animated_sprite:
		animated_sprite.flip_h = (direction == -1)

func cambiar_estado(nuevo_estado):
	current_state = nuevo_estado
	if is_multiplayer_authority():
		_sync_estado.rpc(nuevo_estado)
	if animated_sprite == null: return
	match current_state:
		STATE.IDLE:
			animated_sprite.play("idle")
		STATE.WALK:
			animated_sprite.play("walk")
		STATE.JUMP:
			animated_sprite.play("jump")
		STATE.DEATH:
			morir_jugador()
		STATE.CINEMATIC:
			direction = 0
			animated_sprite.play("idle")

@rpc("authority", "call_remote")
func _sync_estado(estado: int) -> void:
	current_state = estado
	if animated_sprite == null: return
	match estado:
		STATE.IDLE:   animated_sprite.play("idle")
		STATE.WALK:   animated_sprite.play("walk")
		STATE.JUMP:   animated_sprite.play("jump")
		STATE.CINEMATIC:
			direction = 0
			animated_sprite.play("idle")

func procesar_movimiento():
	if is_on_wall():
		direction *= -1
	if Input.is_action_just_pressed("ui_left"): direction = -1
	elif Input.is_action_just_pressed("ui_right"): direction = 1
	if Input.is_action_just_pressed("ui_down") and is_on_floor():
		position.y += 3
		print(health, SPEED, damage, self)
	velocity.x = direction * SPEED
	if animated_sprite:
		animated_sprite.flip_h = (direction == -1)
	if hitbox_attack:
		hitbox_attack.scale.x = direction
		hitbox_attack.position.x = -80 if direction == -1 else 0

func morir_jugador():
	is_dead = true
	velocity = Vector2.ZERO
	if animated_sprite:
		animated_sprite.play("death")
		await animated_sprite.animation_finished
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://ui/GameOver.tscn")

func _on_hit_box_attack_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		if multiplayer.is_server():
			damage_enemy(body.get_path())
		else:
			damage_enemy.rpc_id(1, body.get_path())

@rpc("any_peer")
func damage_enemy(enemy_path):
	if !multiplayer.is_server(): return
	var enemy = get_node_or_null(enemy_path)
	if enemy:
		enemy.receive_damage()

func flash_damage():
	if animated_sprite:
		animated_sprite.modulate = Color(10, 1, 1)
		await get_tree().create_timer(0.15).timeout
		animated_sprite.modulate = Color(1, 1, 1)

func _on_hit_box_player_body_entered(body: Node2D) -> void:
	if not is_multiplayer_authority(): return
	if body.is_in_group("enemies"):
		if "damage" in body:
			if body.damage == 0: return
			health -= body.damage
			print("Daño recibido: ", body.damage, " | Vida restante: ", health)
			flash_damage()
		else:
			print("Error: El enemigo ", body.name, " no tiene variable 'damage'")

func entrar_en_cinematica():
	cambiar_estado(STATE.IDLE)
	current_state = STATE.CINEMATIC

func _aplicar_cuerpo(index: int) -> void:
	if cuerpos.is_empty() or index >= cuerpos.size(): return
	for c in cuerpos:
		if c != null: c.visible = false
	if cuerpos[index] != null:
		cuerpos[index].visible = true
		animated_sprite = cuerpos[index]

func cambiar_cuerpo(index: int) -> void:
	var anim = "idle"
	if animated_sprite != null: anim = animated_sprite.animation
	cuerpo_actual = index
	_aplicar_cuerpo(index)
	if animated_sprite != null: animated_sprite.play(anim)

@rpc("any_peer", "call_local")
func healall():
	for child in get_parent().get_children():
		if child is CharacterBody2D:
			var peer_id = child.get_multiplayer_authority()
			var player = get_parent().get_node(str(peer_id))
			player.max_health += 3
			player.health = player.max_health
@rpc("any_peer", "call_local")
func fastall():
	for child in get_parent().get_children():
		if child is CharacterBody2D:
			var peer_id = child.get_multiplayer_authority()
			var player = get_parent().get_node(str(peer_id))
			player.SPEED += 100

@rpc("any_peer", "call_local")
func boostall():
	for child in get_parent().get_children():
		if child is CharacterBody2D:
			var peer_id = child.get_multiplayer_authority()
			var player = get_parent().get_node(str(peer_id))
			player.damage += 1

func _on_synchronized() -> void:
	if not cuerpos.is_empty():
		_aplicar_cuerpo(cuerpo_actual)
