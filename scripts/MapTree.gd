extends Node

var Room1 = Room.new("", 20)
var Room2 = Room.new("res://visual assets/Objects/BG2-Lab.png", 20)
var Room3 = Room.new("res://visual assets/Objects/BG1-Lab-V2.png", 20)
var Room4 = Room.new("res://visual assets/Objects/BG2-Lab.png", 20)
var Room5 = Room.new("res://visual assets/Objects/BG1-Lab-V2.png", 20)
var Rooms = [Room1, Room2, Room3, Room4, Room5]
func _ready() -> void:
	#este arbol es creado en base al del documento
	Room1.DoorsTo.append(Room2)
	Room1.DoorsTo.append(Room3)
	Room2.DoorsTo.append(Room5)
	Room3.DoorsTo.append(Room4)

	Room2.locked = false
	Room3.locked = false
	
	
	Room1.addButton($TextureRect/Button1)
	Room2.addButton($TextureRect/Button2)
	Room3.addButton($TextureRect/Button3)
	Room4.addButton($TextureRect/Button4)
	Room5.addButton($TextureRect/Button5)
	
	call_deferred("asignarLevelbase")
	
func _process(delta):
	for room in Rooms:
		if room.button != null:
			room.button.disabled = room.locked


func _on_button_6_pressed() -> void:
	self.visible = false
	get_tree().paused = false

func asignarLevelbase():
	for room in Rooms:
		room.Levelbase = get_parent()
