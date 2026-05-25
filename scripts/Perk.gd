"""Aclaraciónes, aquí estan los vértices del
grafo, y funciona provisionalmente, ajustes
que deben hacerse son que los nodos puedan
activarse con un 'costo', y por supuesto que
hagan cierto efecto en el jugador, esto
último sería ideal implementarlo en la función
'_on_button_pressed'"""
extends Node
class_name Perk

var metric
var neighbours = []
var perkType
var perkCode:int
var locked = true
var button:Button
var texture:TextureRect
var player

func _init(v):
	metric = v
	perkCode = randi_range(1, 3)
	
	match perkCode:
		1:
			perkType = "Life"
		2:
			perkType = "Speed"
		3:
			perkType = "Dmg"
			

func unlock():
	self.locked = true
	for neighbour in self.neighbours:
		neighbour.locked = false
		
func _on_button_pressed():
	if(self.locked==false and PLAYER.perkpoints > 0):
		self.unlock()
		if perkCode == 1:
			print(player.health)
			player.healall.rpc()
			print(player.health)
		elif perkCode == 2:
			print(player.SPEED)
			player.fastall.rpc()
			print(player.SPEED)
		elif perkCode == 3:
			print(player.damage)
			player.boostall.rpc()
			print(player.damage)
		PLAYER.perkpoints -= 1
		
func addButton(boton:Button, imagen: TextureRect):
	button = boton
	button.pressed.connect(_on_button_pressed.bind())
	texture = imagen
	if perkCode == 1:
		texture.texture = load("res://visual assets/Objects/botonCorazónNoPresionado.png")
	elif perkCode == 2:
		texture.texture = load("res://visual assets/Objects/botonVelocidadNoPresionado.png")
	elif perkCode == 3:
		texture.texture = load("res://visual assets/Objects/botonAtaqueNoPresionado.png")
