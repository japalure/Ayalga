class_name ContenedorMobs
extends Control

var mobs: Array[Mob] #Guardamos todas las monedas del segmento.
var total_mob: int


func _ready() -> void:
	mobs.clear()
	for child in get_children():
		if child is Mob:
			mobs.append(child)
	total_mob = mobs.size()
