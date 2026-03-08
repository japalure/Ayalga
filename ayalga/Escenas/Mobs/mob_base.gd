class_name Mob
extends CharacterBody2D

var ContenedorMob: ContenedorMobs #Esta referencia se resuelve dentro de ContenedorPiedras

@export var velocidad: float = 40.0
@export var daño: int = 1        # piedras que quita al jugador
@export var resistencia: int = 1    # peso mínimo del jugador para matarlo con culetazo

var direccion := Vector2.LEFT
var en_espera: bool = true
## Métodos de consulta


## Movimiento y comportamiento
func _physics_process(delta: float) -> void:
	if en_espera:
		return
	movimiento(delta)
	
func movimiento(delta:float) -> void:
	velocity = direccion * daño
	move_and_slide()

# Detecta cuando el jugador está en rango
func _on_deteccion_jugador_body_entered(body: Node2D) -> void:
	if !body or body is not Jugador:
		return
	#print ("jugador está en rango de mob")
	en_espera = false
	# Empezar movimiento y dejar de hacer animación idle

func _on_deteccion_jugador_body_exited(body: Node2D) -> void:
	if !body or body is not Jugador:
		return
	en_espera = true

## Daño
func _on_deteccion_golpe_body_entered(body: Node2D) -> void:
	if body is Jugador:
		#print ("ha sido golpeado por jugador")
		if body.haciendo_culetazo():
			#print ("haciendo culetazo")
			recibe_daño(body)
		else:
			#print ("jugador recibe daño")
			body.recibe_daño_mob(self)
			
			
func recibe_daño(body: Node2D) ->void:
	if body is Jugador:
		if body.peso_actual() >= resistencia:
			muerte()
		else:
			body.rebotar()

func muerte() -> void:
	queue_free()
