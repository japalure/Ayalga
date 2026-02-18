class_name Piedra
extends Node2D

# Identificador único de la piedra mientras dure la sesión
@export var id: int = 0
# Textura / sprite asociado al tier (se puede asignar en el editor)
@export var skin: Sprite2D
@export var area_2d: Area2D

var ContenedorPiedra: ContenedorPiedras #Esta referencia se resuelve dentro de ContenedorPiedras

##------------------------A FUTURO-------------------------------------##
## Tier de la piedra: 0 = Bronce, 1 = Plata, 2 = Oro
#enum Tier { BRONCE, PLATA, ORO }
#@export var tier: Tier = Tier.BRONCE
## Peso base por tier
#const PESO_BASE_POR_TIER := {
	#Tier.BRONCE: 1.0,
	#Tier.PLATA:  2.0,
	#Tier.ORO:    3.0,
#}
## Multiplicador de peso (para mejoras, buffs, etc.)
#@export var multiplicador_peso: float = 1.0


func _ready() -> void:
	# ID único durante esta sesión	
	id = get_instance_id()  
	area_2d.body_entered.connect(recogida)


func recogida(_body):
	queue_free()
