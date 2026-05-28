extends CanvasLayer

@onready var my_player
@onready var healthbar = $MarginContainer/VBoxContainer/Healthbar
@onready var damage = $MarginContainer/VBoxContainer/Atack
@onready var totalenemies = $MarginContainer/VBoxContainer/EneTotal
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if my_player:
		healthbar.value = (my_player.health / my_player.max_health) * 100
		damage.text = str(my_player.damage)
		totalenemies.text = str(get_parent().enemies_purified)
	else:
		my_player = get_parent().get_node("SandCointainer").get_node(str(multiplayer.get_unique_id()))

	
