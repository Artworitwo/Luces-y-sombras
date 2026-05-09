extends Node

@onready var rng : RandomNumberGenerator = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func random (min_number, max_number):
	rng.randomize()
	return rng.randf_range(min_number, max_number)
