extends Node2D

@export var goal_purified_enemies:int
var purified_enemies:int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func record_death() -> void:
	purified_enemies += 1
	if (purified_enemies == goal_purified_enemies):
		get_tree().change_scene_to_file("res://scripts/SafeZone.tscn")
