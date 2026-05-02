extends Node
class_name Room
var background:String
var enemieNumber:int
var Boss:bool
var DoorsTo = []
var locked = true
var button:Button
func _init(bg, eN, Chief):
	background = bg
	enemieNumber = eN
	Boss = Chief
func unlock():
	self.locked = true
	for neighbour in self.DoorsTo:
		neighbour.locked = false
		
func _on_button_pressed():
	if(self.locked==false):
		self.unlock()
		
func addButton(boton:Button):
	button = boton
	button.pressed.connect(_on_button_pressed.bind())
	
	



	
