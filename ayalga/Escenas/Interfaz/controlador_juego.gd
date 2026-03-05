#Llama a MapaBase para crear un nuevo nivel a partir de una semilla. 
#controla lógica del juego
#guarda partida
class_name Juego
extends Control

## Nodos
var mapa:Mapa
@export var jugador: Jugador

## Variables de juego
signal piedra_recogida #señal para actualizar label
var piedras_recogidas:int = 0
var record_piedras:int 
signal distancia_actualizada
var distancia_recorrida:float = 0
var record_distancia:float 

## Guardado
@export var partida: DatosPartida
var ruta:String = "user://partida.tres" # ruta en %AppData%
#var ruta:String = "res://partida.tres" # ruta en local para hacer pruebas

func _ready() -> void:
	await get_tree().process_frame
	cargar_partida()
	nuevo_mapa() #en el futuro añadir semilla
	

## Constructores
# Carga un nuevo mapa 
func nuevo_mapa() -> void:
	var panel_principal = get_node_or_null("PanelEscenaPrincipal")
	if not panel_principal:
		#push_error("No se encontró PanelEscenaPrincipal.")
		return
	var mapa_scene = load("res://Escenas/Mapas/MapaBase.tscn")
	mapa = mapa_scene.instantiate() as Mapa
	panel_principal.add_child(mapa)                      

func referencia_jugador(j:Jugador) -> void:
	if j is Jugador and j:
		jugador = j
	else:
		push_error("Fallo al pasar referencia de jugador.")
		
	
		
## Lógica del juego
func sumar_piedra() -> void:
	piedras_recogidas += 1
	if piedras_recogidas > record_piedras:
		record_piedras = piedras_recogidas
	piedra_recogida.emit()
	

	

#Personaje llama a esta función para actualizar la distancia por pantalla
func actualizar_distancia(nueva_distancia: float) -> void:
	distancia_recorrida = nueva_distancia
	if distancia_recorrida > record_distancia:
		record_distancia = distancia_recorrida
	distancia_actualizada.emit()

## Interfaz


## Gestión de partidas
func guardar_partida() -> void:
	partida.distancia = record_distancia
	partida.n_piedras = record_piedras
	
	ResourceSaver.save(partida, ruta)

func cargar_partida() -> void:
	if ResourceLoader.exists(ruta):
		partida = load(ruta)
		record_distancia = partida.distancia
		record_piedras = partida.n_piedras
		#print( "piedra: " + str(partida.n_piedras) + " distancia: " +str(partida.distancia))
	else:
		#push_error("No se encontró partida guardada")
		partida = DatosPartida.new()
