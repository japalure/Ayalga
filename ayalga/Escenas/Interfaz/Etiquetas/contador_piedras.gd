extends Control

@export var label: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ControladorJuego.piedra_recogida.connect(actualizar_texto)


func actualizar_texto() -> void:
	label.text = "Piedras: " +str(ControladorJuego.piedras_recogidas)
	
