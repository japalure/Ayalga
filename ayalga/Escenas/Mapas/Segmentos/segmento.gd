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
## Modificar tiles
@export var rellenar_fondos: bool #True si quieres que los fondos negros se cambien automáticamente
const TILE_SOURCE_ID := 0
const TILE_ATLAS_A_CAMBIAR := Vector2i(1, 3)
@export var tile_map_nivel: TileMapLayer #nodo referencia del tilemap
@export var array_tiles_relleno: Array[Vector2i] #coordenadas de los tiles a rellenar


func _ready() -> void:
	#info()
	await get_tree().process_frame
	reemplazar_1_de_cada_10_tiles()
	
func _process(_delta: float) -> void:
	pass

func setup(id: int):
	id_segmento = id

func reemplazar_1_de_cada_10_tiles():
	if !rellenar_fondos:
		return
	if tile_map_nivel == null:
		return
	if array_tiles_relleno.is_empty():
		return

	var coords_a_cambiar: Array[Vector2i] = []

	# 1) Buscar todas las celdas cuyo tile sea el objetivo
	var used_cells: Array[Vector2i] = tile_map_nivel.get_used_cells()
	for cell in used_cells:
		var source_id := tile_map_nivel.get_cell_source_id(cell)
		if source_id != TILE_SOURCE_ID:
			continue

		var atlas_coords := tile_map_nivel.get_cell_atlas_coords(cell)
		if atlas_coords == TILE_ATLAS_A_CAMBIAR:
			coords_a_cambiar.append(cell)

	# 2) De esa lista, cambiar 1 de cada 20 por un tile aleatorio de array_tiles_relleno
	for i in coords_a_cambiar.size():
		
		if randi() % 20 == 0:
			var random_atlas: Vector2i = array_tiles_relleno.pick_random()  # elemento aleatorio del array[web:27]
			tile_map_nivel.set_cell(
				coords_a_cambiar[i],
				TILE_SOURCE_ID,
				random_atlas
			) 

func info() -> void:
	print ("Segmento id: " + str(id_segmento))
	print ("	" + str(contenedor_piedras.total_piedras) + " piedras")
	print ("	" + str(contenedor_mob.total_mob) + " mobs")
