class_name Mob
extends CharacterBody2D

var ContenedorMob: ContenedorMobs #Esta referencia se resuelve dentro de ContenedorPiedras
var jugador: Jugador #Esta referencia se resuelve cuando el jugador entra en rango

@export var animacion: AnimatedSprite2D

@export var velocidad: float = 50.0
@export var velocidad_ataque: float = 70.0
@export var daño: int = 1        # piedras que quita al jugador
@export var resistencia: int = 1    # peso mínimo del jugador para matarlo con culetazo
var direccion := Vector2.LEFT
var velocidad_actual = 0.0
var en_espera: bool = true

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
	cambiar_animacion(0) #idle
	velocidad_actual = velocidad
	configurar_raycasts()
	call_deferred("configurar_buscador") #navegación

func _physics_process(delta: float) -> void:
	if en_espera:
		return
	if vuela:
		movimiento_aire(delta)
		move_and_slide()
		flotando(delta)
	else:
		patrullar(delta)
		gravedad(delta)
		move_and_slide()
		
	cambiar_orientacion_a_jugador()
	
	
	
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
func movimiento_aire(_delta:float) -> void:
	buscar_camino(_delta) 
	await cambiar_animacion(1) # perseguir

# Patrulla por plataforma
func patrullar(_delta: float) -> void:
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
	cambiar_animacion(3) #ataque
	velocidad_actual = velocidad_ataque

func finalizar_ataque() -> void:
	cambiar_animacion(1) #ataque
	velocidad_actual = velocidad

##-----------------------------Funciones de Daño-----------------------------##
func recibe_daño(body: Node2D) ->void:
	if body is Jugador:
		if body.peso_actual() >= resistencia:
			muerte()
		else:
			body.rebotar()

func muerte() -> void:
	$Colisiones.queue_free() #Para que el jugador no se quede encima
	await cambiar_animacion(2) # morir y esperar a que termine la animación
	queue_free()

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
	if !body or body is not Jugador:
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

func buscar_camino(_delta: float) -> void:
	if jugador:
		navegacion.target_position = jugador.global_position
	
	if navegacion.is_navigation_finished():
		return
	var pos_actual = global_position
	var pos_siguiente = navegacion.get_next_path_position()
	velocity = pos_actual.direction_to(pos_siguiente) * velocidad_actual
