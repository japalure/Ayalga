extends Control

@export var label: Label

func _ready() -> void:
	ControladorJuego.distancia_actualizada.connect(actualizar_texto)

func actualizar_texto() -> void:
	label.text = "Distancia: %.2f px" % abs(ControladorJuego.distancia_recorrida)
	
