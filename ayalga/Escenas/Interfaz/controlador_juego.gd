#Llama a MapaBase para crear un nuevo nivel a partir de una semilla. 
#controla lógica del juego
#guarda partida
class_name Juego
extends Control

signal piedra_recogida
var piedras_recogidas:int = 0
signal distancia_actualizada
var distancia_recorrida:float = 0

var mapa:Mapa
@export var personaje: CharacterBody2D
@export var camara: Camera2D

func _ready() -> void:
	await get_tree().process_frame
	nuevo_mapa() #en el futuro añadir semilla


# Carga un nuevo mapa 
func nuevo_mapa() -> void:
	var panel_principal = get_node_or_null("PanelEscenaPrincipal")
	if not panel_principal:
		push_error("No se encontró PanelEscenaPrincipal.")
		return
	var mapa_scene = load("res://Escenas/Mapas/MapaBase.tscn")
	mapa = mapa_scene.instantiate() as Mapa
	panel_principal.add_child(mapa)                      

func sumar_piedra() -> void:
	piedras_recogidas += 1
	piedra_recogida.emit()

#Personaje llama a esta función para actualizar la distancia por pantalla
func actualizar_distancia(nueva_distancia: float) -> void:
	distancia_recorrida = nueva_distancia
	distancia_actualizada.emit()
