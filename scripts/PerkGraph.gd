extends Node

#CREACIÓN DEL grafo DE HABILIDADES (BUFFOS)
var Perk1 = Perk.new(1)
var Perk2 = Perk.new(2)
var Perk3 = Perk.new(3)
var Perk4 = Perk.new(4)
var Perk5 = Perk.new(5)
var Perk6 = Perk.new(6)
var Perk7 = Perk.new(7)
var Perk8 = Perk.new(8)
var Perk9 = Perk.new(9)
var Perk10 = Perk.new(10)
var perks = [Perk2, Perk3, Perk4, Perk5, Perk6, Perk7, Perk8, Perk9, Perk10]
func _ready():
	Perk1.neighbours.append(Perk2)
	Perk1.neighbours.append(Perk5)
	Perk1.neighbours.append(Perk8)
	Perk2.neighbours.append(Perk3)
	Perk2.neighbours.append(Perk4)
	Perk5.neighbours.append(Perk6)
	Perk5.neighbours.append(Perk7)
	Perk8.neighbours.append(Perk9)
	Perk8.neighbours.append(Perk10)
	
	Perk1.unlock()
	
	Perk2.addButton($TextureRect/Button2, $TextureRect/img2)
	Perk3.addButton($TextureRect/Button3, $TextureRect/img3)
	Perk4.addButton($TextureRect/Button4, $TextureRect/img4)
	Perk5.addButton($TextureRect/Button5, $TextureRect/img5)
	Perk6.addButton($TextureRect/Button6, $TextureRect/img6)
	Perk7.addButton($TextureRect/Button7, $TextureRect/img7)
	Perk8.addButton($TextureRect/Button8, $TextureRect/img8)
	Perk9.addButton($TextureRect/Button9, $TextureRect/img9)
	Perk10.addButton($TextureRect/Button10, $TextureRect/img10)

	
func _process(delta):
	for perk in perks:
		if perk.button != null:
			perk.button.disabled = perk.locked
	if get_parent().get_node("SandCointainer").get_node(str(multiplayer.get_unique_id())):
		for perk in perks:
			if !perk.player:
				perk.player = get_parent().get_node("SandCointainer").get_node(str(multiplayer.get_unique_id()))


func _on_button_pressed() -> void:
	self.visible = false
	get_tree().paused = false
	
