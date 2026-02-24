#Llama a MapaBase para crear un nuevo nivel a partir de una semilla. 
#controla lógica del juego
#guarda partida
class_name Juego
extends Control

signal piedra_recogida
var piedras_recogidas:int = 0

@export var mapa:Mapa 

func _ready() -> void:
	pass # Replace with function body.

func nuevo_mapa() -> void:
	mapa


func sumar_piedra() -> void:
	piedras_recogidas += 1
	piedra_recogida.emit()
