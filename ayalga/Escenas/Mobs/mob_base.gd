class_name Mob
extends Node2D

var ContenedorMob: ContenedorMobs #Esta referencia se resuelve dentro de ContenedorPiedras


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# método que configura el movimiento del mob
# a futuro cad mob tendrá que desscribir su propia animación
func iniciar_animacion() -> void:
	var tween:Tween = create_tween()
	tween.set_loops(0) # 0 para que se repita infinito
	tween.tween_property(self, "position:x", position.x - 20, 1.0)
	tween.tween_property(self, "position:x", position.x + 20, 1.0)
