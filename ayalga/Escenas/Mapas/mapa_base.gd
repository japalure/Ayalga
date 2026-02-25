#Cargará los segmentos, los organizará para crear niveles, creará enemigos y recompensas
#manejará la cámara
class_name Mapa
extends Control


@export var segmento: Segmento
@export var contenedor_segmentos: Control

@export var ruta_normal: String = "res://Segmentos/Normal/"
@export var ruta_checkpoint: String = "res://Segmentos/Checkpoint/"
@export var ruta_tienda: String = "res://Segmentos/Tienda/"  

@export var segmento_inicial: PackedScene #el nivel 0 siempre empezará en este segmento
# Arrays con todos los segmentos de ese tipo ya instanciados
var pool_segmentos_normal: Array[Segmento]
var pool_segmentos_tienda: Array[Segmento]
var pool_segmentos_checkpoint: Array[Segmento]
var segmentos_activos: Array[Segmento]
var siguiente_id: int = 0

var altura_segmento: float = self.custom_minimum_size.y

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var semilla: int =1245 # Seed para random reproducibles
var nivel_actual: int = 0

func _ready(sem:int =semilla) -> void:
	if sem == 1245:  # Default
		rng.randomize()
		#print ("random ", rng.seed)
	else:
		rng.seed = sem 
	limpiar_segmentos()
	cargar_pool_segmentos()
	generar_nivel(nivel_actual)

func _process(_delta: float) -> void:
	pass
	

# Busca en las carpetas de segmentos todos los segmentos creados y los guarda en arrays	
func cargar_pool_segmentos() -> void:
	pool_segmentos_normal = obtener_tscn(ruta_normal)
	pool_segmentos_checkpoint = obtener_tscn(ruta_checkpoint)
	pool_segmentos_tienda = obtener_tscn(ruta_tienda)
	print("Segmentos cargados %d normales, %d checkpoints y %d tiendas" % [pool_segmentos_normal.size(), pool_segmentos_checkpoint.size(), pool_segmentos_tienda.size()])

# Recorre todas las escenas de una carpeta pasada por parámetro
# Instancia esas escenas y devuelve un array con todas las que fuesen de tipo segemento.
func obtener_tscn(carpeta: String) -> Array[Segmento]:
	var escenas: Array[Segmento] = []
	var dir: DirAccess = DirAccess.open(carpeta)
	
	if dir == null:
		push_error("No se pudo abrir: " + carpeta)
		return escenas
	
	dir.list_dir_begin()  # Inicia escaneo
	var archivo = dir.get_next()
	
	while archivo != "":
		if not dir.current_is_dir() and archivo.ends_with(".tscn"):
			var ruta_completa = carpeta.path_join(archivo)
			var escena = load(ruta_completa) as PackedScene
			var instancia = escena.instantiate()
			if instancia and instancia is Segmento:
				escenas.append(instancia)
		archivo = dir.get_next()
	
	dir.list_dir_end()  # Limpia
	return escenas


# Crea un nivel a partir de la pool de segmentos siguiendo la lógica de:
# cada nivel se compone de 8 segmentos normales, 1 de tienda y 1 al final de checkpoint
func generar_nivel(nivel: int) -> void:
	# Aleatoriza el orden de elementos del array
	pool_segmentos_normal.shuffle()
	pool_segmentos_checkpoint.shuffle()
	
	if nivel == 0:
		segmentos_activos.append(segmento_inicial.instantiate())
		
	# i = 1 a 10 o size-1 (el menor)
	for i in range(0, min(9, pool_segmentos_normal.size())):
		var seg: Segmento = pool_segmentos_normal[i]
		segmentos_activos.append(seg)
	segmentos_activos.append(pool_segmentos_checkpoint[0])
	add_segmentos_mapa()


func add_segmentos_mapa() -> void:
	var i:int = 0
	for seg in segmentos_activos:
		contenedor_segmentos.add_child(seg)
		#seg.conectar_signals(self)  # Para detectar llegada jugador
		seg.position.y = +i * altura_segmento
		i+=1

func limpiar_segmentos() -> void:
	segmentos_activos.clear()
	
	for child in contenedor_segmentos.get_children():
		child.queue_free()
