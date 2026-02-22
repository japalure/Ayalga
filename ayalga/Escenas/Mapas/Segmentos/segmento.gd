class_name Segmento
extends Control

enum TipoSegmento {
	INCIO,
	NORMAL,     
	CHECKPOINT, 
	TIENDA  
}

var id_segmento: int = 0
@export var contenedor_piedras: ContenedorPiedras
@export var contenedor_mob: ContenedorMobs
@export var tipo: TipoSegmento = TipoSegmento.NORMAL


func _ready() -> void:
	#info()
	pass
	
func _process(_delta: float) -> void:
	pass

func setup(id: int):
	id_segmento = id

func info() -> void:
	print ("Segmento id: " + str(id_segmento))
	print ("	" + str(contenedor_piedras.total_piedras) + " piedras")
	print ("	" + str(contenedor_mob.total_mob) + " mobs")
