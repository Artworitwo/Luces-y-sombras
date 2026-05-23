extends Node
var next_room: String

var nonactive: bool
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	next_room = "res://visual assets/Objects/BG3-zonaSegura.png"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func open():
	$AnimatedSprite2D2.play("lockopen")
	await $AnimatedSprite2D2.animation_finished
	$AnimatedSprite2D2.visible = false
	$AnimatedSprite2D.play("Open")
	await $AnimatedSprite2D.animation_finished
	$CollisionShape2D.disabled = false
	


func _on_body_entered(body: Node2D) -> void:
	if $CollisionShape2D.disabled == false:
		get_parent().changeBack.rpc(next_room)
		$CollisionShape2D.disabled = true
		$AnimatedSprite2D.play_backwards("Open")
		await $AnimatedSprite2D.animation_finished
		$AnimatedSprite2D2.visible = true
		$AnimatedSprite2D2.play_backwards("lockopen")
