extends Node
class_name Room
var background:String
var enemieNumber:int
var Boss:bool
var DoorsTo = []
var locked = true
var button:Button
var Levelbase
func _init(bg, eN):
	background = bg
	enemieNumber = eN
	
func unlock():
	self.locked = true
	for neighbour in self.DoorsTo:
		neighbour.locked = false
		
func _on_button_pressed():
	if(self.locked==false and Levelbase.passpoints > 0):
		Levelbase.get_node("Door").next_room = background
		Levelbase.openthedoor()
		self.unlock()
		Levelbase.passpoints -= 1
		
func addButton(boton:Button):
	button = boton
	button.pressed.connect(_on_button_pressed.bind())
	
	



	
