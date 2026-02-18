#Cargará los segmentos, los organizará para crear niveles, creará enemigos y recompensas
#manejará la cámara
extends Control

@export var personaje: CharacterBody2D
@export var camara: Camera2D
@export var segmento: Segmento
@export var contenedor_segmentos: Control

@export var ruta_normal: String = "res://Segmentos/Normal/"
@export var ruta_checkpoint: String = "res://Segmentos/Checkpoint/"
@export var ruta_tienda: String = "res://Segmentos/Tienda/"  

var pool_segmentos_normal: Array[Segmento]
var pool_segmentos_tienda: Array[Segmento]
var pool_segmentos_checkpoint: Array[Segmento]

var segmentos_activos: Array[Segmento]
var siguiente_id: int = 0

var altura_segmento: int = self.custom_minimum_size.y

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var semilla: int # Seed para random reproducibles
var nivel_actual: int = 0

func _ready(semilla: int  = 1245) -> void:
	rng.seed = semilla
	cargar_pool_segmentos()

func _process(delta: float) -> void:
	pass
	
# Busca en las carpetas de segmentos todos los segmentos creados y los guarda en arrays	
func cargar_pool_segmentos() -> void:
	pool_segmentos_normal = obtener_tscn(ruta_normal)
	pool_segmentos_checkpoint = obtener_tscn(ruta_checkpoint)
	pool_segmentos_tienda = obtener_tscn(ruta_tienda)
	print("Cargados %d normales, %d checkpoints y %d tiendas" % [pool_segmentos_normal.size(), pool_segmentos_checkpoint.size(), pool_segmentos_tienda.size()])

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
			if escena and escena is Segmento:
				escenas.append(escena)
		archivo = dir.get_next()
	
	dir.list_dir_end()  # Limpia
	return escenas

func generar_nivel(nivel: int):
	limpiar_segmentos()
	var indices_normales = rng.randi_array(pool_segmentos_normal.size(), 9)  # 9 únicos aleatorios
	var orden = indices_normales.shuffle() + [rng.randi_range(0, pool_segmentos_checkpoint.size()-1)]
	
	for i in 10:
		var seg_scene: Segmento = pool_segmentos_normal[orden[i]] if i < 9 else pool_segmentos_checkpoint[orden[9]]
		var segmento = seg_scene.instantiate()
		segmento.position.y = -i * altura_segmento  # Apila de arriba abajo
		segmento.conectar_signals(self)  # Para detectar llegada jugador
		contenedor_segmentos.add_child(segmento)
		segmentos_activos.append(segmento)
	
	actualizar_camara()

func limpiar_segmentos() -> void:
	segmentos_activos.clear()

func actualizar_camara() -> void:
	pass
