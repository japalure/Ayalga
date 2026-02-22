class_name ContenedorPiedras
extends Control

var piedras: Array[Piedra] #Guardamos todas las monedas del segmento.
var total_piedras: int


func _ready() -> void:
	piedras.clear()
	for child in get_children():
		if child is Piedra:
			piedras.append(child)
	total_piedras = piedras.size()	
	
	# Le asignamos a cada piedra una referencia a este contenedor
	for piedra in piedras:
		piedra.ContenedorPiedra = self 
