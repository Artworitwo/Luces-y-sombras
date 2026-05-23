extends Node

var Room1 = Room.new("image", 20, false)
var Room2 = Room.new("image", 20, false)
var Room3 = Room.new("image", 20, false)
var Room4 = Room.new("image", 20, false)
var Room5 = Room.new("image", 20, true)
var Rooms = [Room1, Room2, Room3, Room4, Room5]
func _ready() -> void:
	#este arbol es creado en base al del documento
	Room1.DoorsTo.append(Room2)
	Room1.DoorsTo.append(Room3)
	Room2.DoorsTo.append(Room5)
	Room3.DoorsTo.append(Room4)
	Room3.DoorsTo.append(Room5)
	Room4.DoorsTo.append(Room5)
	
	Room1.locked = false
	
	Room1.addButton($TextureRect/Button)
	Room2.addButton($TextureRect/Button2)
	Room3.addButton($TextureRect/Button3)
	Room4.addButton($TextureRect/Button4)
	Room5.addButton($TextureRect/Button5)
	
func _process(delta):
	for room in Rooms:
		if room.button != null:
			room.button.disabled = room.locked
	
	


func _on_button_6_pressed() -> void:
	self.visible = false
	get_tree().paused = false
