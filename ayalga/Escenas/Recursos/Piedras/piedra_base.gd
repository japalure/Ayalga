class_name Piedra
extends Control

# Identificador único de la piedra mientras dure la sesión
static var next_id: int = 0
var id: int
# Textura / sprite asociado al tier (se puede asignar en el editor)
@export var skin: TileMapLayer
@export var tile_map_id: int
@export var area_2d: Area2D
@export var en_mochila: bool = false

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
	id = next_id
	next_id += 1
	#print("Instancia creada con ID: ", id)
	area_2d.body_entered.connect(recogida)
	aplicar_skin(randi_range(0, 3))

func recogida(_body):
	if en_mochila:
		return
	await self.no_recogible()
	ControladorJuego.sumar_piedra()
	if _body is Jugador:
		await _body.pasar_piedra_mochila(self)
	
	await get_tree().process_frame  
	queue_free()

func no_recogible():
	en_mochila = true
	area_2d.visible = false
	if area_2d.body_entered.is_connected(recogida):
		area_2d.body_entered.disconnect(recogida)
	
#cambia el tile de la piedra 
func aplicar_skin(indice: int):
	skin.set_cell(
		Vector2i(0, -1),
		tile_map_id,
		Vector2i(indice, 9)
	)
