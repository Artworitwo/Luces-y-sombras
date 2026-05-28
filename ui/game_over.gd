extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_reboot_pressed() -> void:
	# 1. Quitar la pausa
	get_tree().paused = false
	
	# 2. LIMPIAR LA RED (Fundamental para que no haya errores de puerto)
	multiplayer.multiplayer_peer = null
	
	# 3. Volver a la escena inicial
	get_tree().change_scene_to_file("res://scenes/Create.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
