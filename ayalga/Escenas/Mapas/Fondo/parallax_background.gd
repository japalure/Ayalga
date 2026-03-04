extends ParallaxBackground

@export var color: Color = Color(0.5, 0.5, 0.6, 1.0)
@onready var padre: ParallaxBackground = $"."


func _ready() -> void:
	await get_tree().process_frame
	modular_todas_capas()
	
# Cambia la tonalidad de todas las capas usando el color del inspector
func modular_todas_capas() -> void:
	for _layer in padre.get_children():
		if _layer and _layer is ParallaxLayer:
			_layer.modulate = color
