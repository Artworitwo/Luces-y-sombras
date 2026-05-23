extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.get_multiplayer_authority() != 1: return
	if $Area2D/CollisionShape2D.disabled == false:
		get_parent().showMap(true)
		get_tree().paused = true
	print("show map")


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if body.get_multiplayer_authority() != 1: return
	if $Area2D2/CollisionShape2D.disabled == false:
		get_parent().showTree(true)
		get_tree().paused = true
	print("show tree")
	
func activarAreas():
	if !multiplayer.is_server(): return
	$Area2D2/CollisionShape2D.set_deferred("disabled", false)
	$Area2D/CollisionShape2D.set_deferred("disabled", false)
