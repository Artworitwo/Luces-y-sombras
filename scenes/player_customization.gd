extends Node2D

var player = null
var skin_actual = 0
var total_skins = 2

func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	
	var svc = get_node_or_null("SubViewportContainer")
	print("SubViewportContainer: ", svc)
	if svc:
		print("  posicion: ", svc.position)
		print("  size: ", svc.size)
		print("  visible: ", svc.visible)

	# Diagnóstico del SubViewport
	var sv = get_node_or_null("SubViewportContainer/SubViewport")
	print("SubViewport: ", sv)
	if sv:
		print("  size: ", sv.size)
	if svc:
		svc.size = Vector2(600, 600)
		svc.position = Vector2(-700, -300)
	if sv:
		sv.size = Vector2(600, 600)
	
	player = get_node_or_null("SubViewportContainer/SubViewport/Player")
	
	print("Player: ", player)
	
	if player != null:
		print("Hijos del player en SubViewport:")
		for c in player.get_children():
			print("  '", c.name, "' | ", c.get_class())
	else:
		# Imprime todo el árbol para ver qué hay
		print("=== ÁRBOL COMPLETO ===")
		_imprimir_arbol(self, 0)

	player = get_node_or_null("SubViewportContainer/SubViewport/Player")

	if player == null:
		push_error("No se encontró el Player en el SubViewport")
		return
		
	player.position = Vector2(150, 300)
	# Inicia con la skin guardada
	skin_actual = PLAYERCHARACTER.cuerpo_actual
	player.cambiar_cuerpo(skin_actual)

func _on_siguienteskin_pressed() -> void:
	skin_actual = (skin_actual + 1) % total_skins
	player.cambiar_cuerpo(skin_actual)
	PLAYERCHARACTER.cuerpo_actual = skin_actual  # guarda la elección

func _on_anteriorskin_pressed() -> void:
	skin_actual = (skin_actual - 1 + total_skins) % total_skins
	player.cambiar_cuerpo(skin_actual)
	PLAYERCHARACTER.cuerpo_actual = skin_actual  # guarda la elección

func _imprimir_arbol(nodo: Node, nivel: int) -> void:
	print("  ".repeat(nivel) + nodo.name + " (" + nodo.get_class() + ")")
	for hijo in nodo.get_children():
		_imprimir_arbol(hijo, nivel + 1)
