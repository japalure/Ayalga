class_name Mob
extends CharacterBody2D

var ContenedorMob: ContenedorMobs #Esta referencia se resuelve dentro de ContenedorPiedras
var jugador: Jugador #Esta referencia se resuelve cuando el jugador entra en rango

@onready var animacion: AnimatedSprite2D = $AnimatedSprite2D

enum EstadoMob { IDLE, PATRULLA, PERSEGUIR, ATAQUE, MUERTO }
@export var estado_actual: EstadoMob = EstadoMob.IDLE
@export var velocidad: float = 50.0
@export var velocidad_ataque: float = 70.0
@export var daño: int = 1        # piedras que quita al jugador
@export var resistencia: int = 1    # peso mínimo del jugador para matarlo con culetazo
@export var mirar_jugador: bool = true # el sprite mirará siempre hacia el jugador
var direccion := Vector2.LEFT
var velocidad_actual = 0.0

# Flotar
@export var vuela: bool = false # Activar para mobs voladores
@export var flotar_amplitud: float = 2.0
@export var flotar_velocidad: float = 2.0
var tiempo_flotar := 0.0

# Raycast
@export var distancia_raycast: float = 12.0
@onready var raycast_suelo: RayCast2D = $RayCastSuelo
@onready var raycast_pared: RayCast2D = $RayCastPared

# Navegación
@onready var navegacion: NavigationAgent2D = $NavigationAgent2D
var target: Node2D = null

func _ready() -> void:
	velocidad_actual = velocidad
	configurar_raycasts()
	call_deferred("configurar_buscador") #navegación

func _physics_process(delta: float) -> void:
	if !vuela:
		gravedad(delta)
	else:
		flotando(delta)
	
	match estado_actual:
		EstadoMob.IDLE:
			maquina_idle(delta)
		EstadoMob.PATRULLA:
			maquina_patrulla(delta)
		EstadoMob.PERSEGUIR:
			maquina_perseguir(delta)
		EstadoMob.ATAQUE:
			maquina_ataque(delta)
		EstadoMob.MUERTO:
			return
	
	cambiar_orientacion_a_jugador()
	move_and_slide()
	
	
##-------------------------------Funciones de estado-------------------------------##
func cambiar_estado(nuevo_estado: EstadoMob) -> void:
	#print("cambio de ", estado_actual, " a ", nuevo_estado)
	estado_actual = nuevo_estado
	match estado_actual:
		EstadoMob.IDLE:      animacion.play("idle")
		EstadoMob.PERSEGUIR: animacion.play("perseguir")
		EstadoMob.MUERTO:    maquina_muerto() #La animación no se ejecuta aquí para poder controlar cuando termina
		EstadoMob.ATAQUE:    animacion.play("ataque")
		EstadoMob.PATRULLA:  animacion.play("patrulla")
	
	#await animacion.animation_finished

func maquina_idle(_delta: float) -> void:
	velocity = Vector2.ZERO

func maquina_patrulla(delta: float) -> void:
	if vuela:
		pass
	else:
		patrullar_suelo(delta) 

func maquina_perseguir(delta: float) -> void:
	if vuela:
		perseguir_aire(delta)
	else:
		patrullar_suelo(delta) # A futuro perseguir_suelo

func maquina_ataque(_delta: float) -> void:
	iniciar_ataque()
	if vuela:
		perseguir_aire(_delta)
	else:
		patrullar_suelo(_delta) # A futuro perseguir_suelo

func maquina_muerto() -> void:
	muerte()
##-----------------------------Funciones de Movimiento-----------------------------##
func perseguir_aire(_delta:float) -> void:
	var siguiente_direccion: Vector2 = buscar_camino(jugador)
	velocity = siguiente_direccion * velocidad_actual 


# Patrulla por plataforma
func patrullar_suelo(_delta: float) -> void:
	if not raycast_suelo.is_colliding() or raycast_pared.is_colliding():
		direccion.x *= -1
		animacion.flip_h = direccion.x > 0
	actualizar_raycasts()
	velocity.x = direccion.x * velocidad_actual

func gravedad(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

# Mueve al mob para que parezca que flote 
func flotando(delta: float) -> void:
	if !vuela:
		return
	tiempo_flotar += delta * flotar_velocidad
	var offset_y = sin(tiempo_flotar) * flotar_amplitud
	velocity.y = offset_y * 10.0
	move_and_slide()

		
func iniciar_ataque() -> void:
	velocidad_actual = velocidad_ataque

func finalizar_ataque() -> void:
	velocidad_actual = velocidad

func cambiar_orientacion_a_jugador() -> void:
	if jugador == null or !mirar_jugador:
		return
	
	# sign devuelve 1 si está a la derecha, -1 a la izquierda  y 0 igual
	var direccion_x = sign(jugador.global_position.x - global_position.x)
	# Si está a la derecha, flip_h = true (mira izquierda)
	# Si está a la izquierda, flip_h = false (mira derecha)
	animacion.flip_h = direccion_x > 0
##-----------------------------Funciones de Daño-----------------------------##
func recibe_daño(body: Node2D) ->void:
	if body is Jugador:
		if body.peso_actual() >= resistencia:
			cambiar_estado(EstadoMob.MUERTO) # morir y esperar a que termine la animación
		else:
			body.rebotar()

func muerte() -> void:
	if $Colisiones:
		$Colisiones.queue_free() #Para que el jugador no se quede encima
	#Esperamos a que termine la animación de morir antes de borrar el Mob
	animacion.play("morir")
	await animacion.animation_finished
	queue_free()

##-----------------------------Funciones de Áreas-----------------------------##
# Detecta cuando el jugador está en rango
func _on_deteccion_jugador_body_entered(body: Node2D) -> void:
	if !body or body is not Jugador:
		return
	#print ("jugador está en rango de mob")
	jugador = body
	cambiar_estado(EstadoMob.PERSEGUIR)
	# Empezar movimiento y dejar de hacer animación idle

# Detecta cuando el jugador sale del rango
func _on_deteccion_jugador_body_exited(body: Node2D) -> void:
	if !body or body is not Jugador:
		return
	cambiar_estado(EstadoMob.IDLE)
	#print ("salió de rango")

# Detecta cuando el jugador está suficiente cerca como para empezar a atacar
func _on_deteccion_rango_ataque_body_entered(body: Node2D) -> void:
	if !body or body is not Jugador:
		return
	cambiar_estado(EstadoMob.ATAQUE)

# Detecta si el jugador sale del rango de ataque
func _on_deteccion_rango_ataque_body_exited(body: Node2D) -> void:
	if !body or body is not Jugador:
		return
	finalizar_ataque()
	cambiar_estado(EstadoMob.PERSEGUIR)

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

##-----------------------------Funciones de Raycast---------------------------##
func configurar_raycasts() -> void:
	raycast_suelo.target_position.y = distancia_raycast
	raycast_pared.target_position.x = distancia_raycast
	actualizar_raycasts()

# Actualiza orientación de raycasts
func actualizar_raycasts() -> void:
	var dir_sign :float = sign(direccion.x)
	if dir_sign == 0:
		dir_sign = -1
	
	raycast_suelo.target_position.x = abs(raycast_suelo.target_position.x) * dir_sign
	raycast_suelo.target_position.y = 32 
	raycast_pared.target_position.x = abs(raycast_pared.target_position.x) * dir_sign
	
	raycast_suelo.force_raycast_update()
	raycast_pared.force_raycast_update()

##-----------------------------Funciones de Navegación---------------------------##
func configurar_buscador() -> void:
	await get_tree().process_frame
	if jugador:
		target = jugador

# Devuelve siguiente posición en el camino desde nodo actual a objetivo
func buscar_camino(objetivo: Node2D) -> Vector2:
	if objetivo:
		target = objetivo
	else:
		return global_position
		
	navegacion.target_position = target.global_position
	
	if navegacion.is_navigation_finished():
		return global_position
	var pos_actual = global_position
	var pos_siguiente = navegacion.get_next_path_position()
	return pos_actual.direction_to(pos_siguiente)
