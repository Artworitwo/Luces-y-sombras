extends Node2D
#
var skin_actual = 0
var total_skins = 2

var _sprites_preview: Array = []

var pelo_actual = 0
var total_pelos = 4

var _hair_preview: Array = []
#
func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	
	for s in find_children("*", "AnimatedSprite2D", true, false):
		if s.get_parent().name == "Hairs":
			_hair_preview.append(s as AnimatedSprite2D)
		else:
			_sprites_preview.append(s as AnimatedSprite2D)
		
	_aplicar_pelo_preview(pelo_actual)
	_aplicar_preview(skin_actual)
	
	if _sprites_preview == null:
		push_error("No se encontró PlayerPreview")
		return
		
	skin_actual = CREATE.cuerpo_actual
	pelo_actual = CREATE.pelo_actual
	
func _aplicar_preview(index: int) -> void:
	for i in _sprites_preview.size():
		_sprites_preview[i].visible = (i == index)
	if _sprites_preview.size() > index:
		_sprites_preview[index].play("idle")
		
func _aplicar_pelo_preview(index: int) -> void:
	for h in range(_hair_preview.size()):
		_hair_preview[h].visible = (h == index)

	if _hair_preview.size() > index:
		_hair_preview[index].play("idle")
		
func _on_siguientepelo_pressed() -> void:
	pelo_actual = (pelo_actual + 1) % total_pelos
	_aplicar_pelo_preview(pelo_actual)
	CREATE.pelo_actual = pelo_actual
	CREATE._enviar_pelo.rpc_id(1, pelo_actual)
	
func _on_anteriorpelo_pressed() -> void:
	pelo_actual = (pelo_actual - 1 + total_pelos) % total_pelos
	_aplicar_pelo_preview(pelo_actual)
	CREATE.pelo_actual = pelo_actual
	CREATE._enviar_pelo.rpc_id(1, pelo_actual)

func _on_siguienteskin_pressed() -> void:
	skin_actual = (skin_actual + 1) % total_skins
	_aplicar_preview(skin_actual)
	CREATE.cuerpo_actual = skin_actual
	CREATE._enviar_skin.rpc_id(1, skin_actual)

func _on_anteriorskin_pressed() -> void:
	skin_actual = (skin_actual - 1 + total_skins) % total_skins
	_aplicar_preview(skin_actual)
	CREATE.cuerpo_actual = skin_actual
	CREATE._enviar_skin.rpc_id(1, skin_actual)


func _on_salir_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Create.tscn")
