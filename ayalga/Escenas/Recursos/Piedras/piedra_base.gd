extends Node2D


# Identificador único de la piedra mientras dure la sesión
@export var id: int = 0
# Textura / sprite asociado al tier (se puede asignar en el editor)
@export var skin: Texture2D

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
	# Asignar la skin al sprite si está definida
	var sprite := get_node_or_null("Sprite2D")
	if sprite and skin:
		sprite.texture = skin
	
	# ID único durante esta sesión	
	id = get_instance_id()  
