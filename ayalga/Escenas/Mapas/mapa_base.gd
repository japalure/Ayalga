#Cargará los segmentos, los organizará para crear niveles, creará enemigos y recompensas
#manejará la cámara
extends Control

@export var personaje:CharacterBody2D
@export var camara:Camera2D

var segmentos: Array[PackedScene]
var segmentos_tienda: Array[PackedScene]
var segmentos_checkpoint: Array[PackedScene]


func _ready(semilla: int = 0) -> void:
	pass

func _process(delta: float) -> void:
	pass
	
func cargar_segmentos() -> void:
	pass
