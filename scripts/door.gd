extends Node
var zonasegura = preload("res://visual assets/enemies/temporalboss.jpg")
var nonactive: bool
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func open():
	$AnimatedSprite2D.play("Open")
	await $AnimatedSprite2D.animation_finished
	$CollisionShape2D.disabled = false


func _on_body_entered(body: Node2D) -> void:
	if $CollisionShape2D.disabled == false:
		get_parent().changeBack(zonasegura)
		$CollisionShape2D.disabled = true
		$AnimatedSprite2D.play_backwards("Open")
