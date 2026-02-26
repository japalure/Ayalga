extends StaticBody2D

@onready var sprite:TileMapLayer = $TileMapLayer
@onready var timer:Timer = $Timer

var tiempo = 1

func _ready():
	set_process(false)

func _process(delta: float) -> void:
	tiempo += 1
	sprite.position += Vector2(0, sin(tiempo) * 2)
	
func _on_deteccion_area_body_entered(body: Node2D) -> void:
	if body is Jugador and body.haciendo_culetazo():
		set_process(true)
		timer.start(0.7)
		#
	#if ControladorJuego.personaje.haciendo_culetazo():  # Solo rompe con culetazo
		## Verificar peso opcional del GDD
		## if jugador.peso_total >= peso_requerido:
		## romper_plataforma()
		#pass


func _on_timer_timeout() -> void:
	queue_free()
