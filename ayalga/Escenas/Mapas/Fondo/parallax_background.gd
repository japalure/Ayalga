extends ParallaxBackground

@export var color: Color = Color(0.5, 0.5, 0.6, 1.0)
@onready var padre: ParallaxBackground = $"."
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	
	for layer in padre.get_children():
		if layer and layer is ParallaxLayer:
			layer.modulate = color
