class_name Mochila
extends Control

@onready var vbox: VBoxContainer = $VBoxContainer
@export var tam_max: int  = 10



func _ready():
	vbox.rotation = deg_to_rad(180) #La mochila se rota para que la piedra en la pos 0 sea la de abajo

func _process(_delta: float) -> void:
	await get_tree().process_frame
	recalcular_posicion()

##-----------------------------Funciones de estado-----------------------------##
func n_piedras() -> int:
	return vbox.get_children().size()

##-----------------------------Funciones visuales-----------------------------##
# Recalcula la posición del vbox dependiendo del número de piedras que tenga la mochila
func recalcular_posicion() -> void:
	#var piedra_size_y:int  = 32
	#var separacion = vbox.get_theme_constant("separation", "VBoxContainer")
	#vbox.position.y = - n_piedras() * (piedra_size_y + separacion)
	pass


##-----------------------------Gestión de piedras-----------------------------##
# Añade la piedra al vbox en primera posición y sube la posición del vbox para que se mantenga centrado
func anadir_piedra(piedra_recogida: Piedra) -> void:
	if n_piedras() < tam_max:
		var nueva_piedra = duplicar_piedra(piedra_recogida)

		
		vbox.call_deferred("add_child", nueva_piedra)
		vbox.call_deferred("move_child", nueva_piedra, 0)
		
		recalcular_posicion()
		ControladorJuego.sumar_piedra()
	else:
		#print("Mochila llena")
		pass

# Crea una copia
func duplicar_piedra(p: Piedra) -> Piedra:
	var nueva_piedra = p.duplicate()
	
	nueva_piedra.no_recogible()
	nueva_piedra.position = Vector2.ZERO
	nueva_piedra.id = p.id
	nueva_piedra.skin = p.skin
	#nueva_piedra.rotar_skin() #Rotar skin para compensar rotación vbox
	
	p.eliminarse()
	
	return nueva_piedra

# Elimna las n piedras más abajo de la mochila
func perder_piedras(n:int) -> void:
	for i in range(0, n):
		if n_piedras() <= 0:
			return
		eliminar_piedra(-1, 0)

# Quitar piedra de la mochila por posición de la piedra o por id
func eliminar_piedra(id:int = -1, pos:int = -1) -> void:
	if id < 0 and pos < 0:
		push_error("id y pos en eliminar_piedra (Mochila) erróneas")
		return
	if id >= 0:
		for piedra in vbox.get_children():
			if piedra.id == id:
				piedra.queue_free()
				vbox.queue_sort()  # Reordena hijos
	if pos >=0 and vbox.get_children().size() > pos:
		#vbox.get_children()[pos].queue_free()
		vbox.get_child(pos).queue_free()
		
	recalcular_posicion()
