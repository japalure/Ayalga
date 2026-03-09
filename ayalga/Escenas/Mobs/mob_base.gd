class_name Mob
extends CharacterBody2D

var ContenedorMob: ContenedorMobs #Esta referencia se resuelve dentro de ContenedorPiedras
var jugador: Jugador

@export var animacion: AnimatedSprite2D

@export var velocidad: float = 100.0
@export var velocidad_ataque: float = 145.0
@export var daño: int = 1        # piedras que quita al jugador
@export var resistencia: int = 1    # peso mínimo del jugador para matarlo con culetazo

# varibles para flotar
@export var flotar: bool = false # Activar para mobs voladores
@export var flotar_amplitud: float = 2.0
@export var flotar_velocidad: float = 2.0
var tiempo_flotar := 0.0

var direccion := Vector2.LEFT
var velocidad_actual = 0.0
var en_espera: bool = true

func _ready() -> void:
	cambiar_animacion(0) #idle
	velocidad_actual = velocidad

func _physics_process(delta: float) -> void:
	if en_espera:
		return
	movimiento(delta)
	cambiar_orientacion_a_jugador()
	flotando(delta)
	move_and_slide()
	
##-------------------------------Funciones de estado-------------------------------##
func cambiar_animacion(id:int) -> void:
	match id:
		0:
			animacion.play("idle")
		1:
			animacion.play("perseguir")
		2:
			animacion.play("morir")
		3:
			animacion.play("ataque")
		4:
			animacion.play("patrulla")
		_:
			animacion.play("idle")
	await animacion.animation_finished

func cambiar_orientacion_a_jugador() -> void:
	if jugador == null:
		return
	
	# sign devuelve 1 si está a la derecha, -1 a la izquierda  y 0 igual
	var direccion_x = sign(jugador.global_position.x - global_position.x)
	# Si está a la derecha, flip_h = true (mira izquierda)
	# Si está a la izquierda, flip_h = false (mira derecha)
	animacion.flip_h = direccion_x > 0

##-----------------------------Funciones de Movimiento-----------------------------##
func movimiento(_delta:float) -> void:
	if jugador:
		var dir = (jugador.global_position - global_position).normalized()
		velocity = dir * velocidad_actual
		await cambiar_animacion(1) # perseguir

# Mueve al mob para que parezca que flote 
func flotando(delta: float) -> void:
	if !flotar:
		return
	
	tiempo_flotar += delta * flotar_velocidad
	var offset_y = sin(tiempo_flotar) * flotar_amplitud
	velocity.y = offset_y * 10.0 
	
func iniciar_ataque() -> void:
	cambiar_animacion(3) #ataque
	velocidad_actual = velocidad

func finalizar_ataque() -> void:
	cambiar_animacion(1) #ataque
	velocidad_actual = velocidad_ataque

##-----------------------------Funciones de Áreas-----------------------------##
# Detecta cuando el jugador está en rango
func _on_deteccion_jugador_body_entered(body: Node2D) -> void:
	if !body or body is not Jugador:
		return
	#print ("jugador está en rango de mob")
	jugador = body
	en_espera = false
	# Empezar movimiento y dejar de hacer animación idle

# Detecta cuando el jugador sale del rango
func _on_deteccion_jugador_body_exited(body: Node2D) -> void:
	if body and body is Jugador:
		return
	en_espera = true
	cambiar_animacion(0) #idle

# Detecta cuando el jugador está suficiente cerca como para empezar a atacar
func _on_deteccion_rango_ataque_body_entered(body: Node2D) -> void:
	if body and body is Jugador:
		iniciar_ataque()

# Detecta si el jugador sale del rango de ataque
func _on_deteccion_rango_ataque_body_exited(body: Node2D) -> void:
	if body and body is Jugador:
		finalizar_ataque()

# Detecta cuando colisiona con un jugador
func _on_deteccion_golpe_body_entered(body: Node2D) -> void:
	if body is Jugador:
		#print ("ha sido golpeado por jugador")
		if body.haciendo_culetazo():
			#print ("haciendo culetazo")
			recibe_daño(body)
		else:
			#print ("jugador recibe daño")
			body.recibe_daño_mob(self)

##-----------------------------Funciones de Daño-----------------------------##
func recibe_daño(body: Node2D) ->void:
	if body is Jugador:
		if body.peso_actual() >= resistencia:
			muerte()
		else:
			body.rebotar()

func muerte() -> void:
	await cambiar_animacion(2) # morir y esperar a que termine la animación
	queue_free()
