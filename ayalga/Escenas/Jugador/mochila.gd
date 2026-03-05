class_name Mochila
extends Control

@onready var vbox: VBoxContainer = $VBoxContainer

func _ready():
	pass

func _process(_delta: float) -> void:
	pass

# Añade la piedra al vbox en primera posición y sube la posición del vbox para que se mantenga centrado
func anadir_piedra(piedra_recogida: Piedra) -> void:
	var nueva_piedra = await duplicar_piedra(piedra_recogida)
	vbox.call_deferred("add_child", nueva_piedra)
	await get_tree().process_frame
	vbox.move_child(nueva_piedra, 0)
	vbox.queue_sort()  # Reordena hijos
	var separacion = vbox.get_theme_constant("separation", "VBoxContainer")
	vbox.position.y = vbox.position.y - nueva_piedra.custom_minimum_size.y - separacion

# Crea una copia
func duplicar_piedra(p: Piedra) -> Piedra:
	var nueva_piedra = p.duplicate()
	await p.no_recogible()
	await get_tree().process_frame  
	nueva_piedra.position = Vector2.ZERO
	nueva_piedra.id = p.id
	nueva_piedra.skin = p.skin
	return nueva_piedra
	
