extends Node
var level = preload("res://scenes/LevelBase.tscn")

func _on_server_pressed() -> void:
	CREATE.start_server()
	get_tree().change_scene_to_packed(level)

func _on_client_pressed() -> void:
	CREATE.start_client()
	get_tree().change_scene_to_packed(level)
	

func _on_opciones_pressed() -> void:
	pass
	get_tree().change_scene_to_file("res://scenes/Player_customization.tscn")
