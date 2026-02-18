class_name Segmento
extends Control

enum TipoSegmento {
	NORMAL,     
	CHECKPOINT, 
	TIENDA  
}

var id_segmento: int
@export var contenedor_piedras: ContenedorPiedras
@export var tipo: TipoSegmento = TipoSegmento.NORMAL


func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass

func setup(id: int):
	id_segmento = id
