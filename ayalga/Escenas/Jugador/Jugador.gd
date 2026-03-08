class_name Jugador
extends CharacterBody2D

@export var animacion: AnimatedSprite2D
@export var area_daño: Area2D
@export var raycast_suelo: RayCast2D
@onready var mochila: Mochila = $Mochila


#movimiento
const velocidad:float = 300.0
const velocidad_salto:float = -600.0
var tiempo_en_aire: float = 0.0;
var velocidad_rebote: float = -400 
#culetazo
var altura_inicial_culetazo: float = 0.0
const distancia_culetazo:float = 200.0
const velocidad_culetazo:float = 300.0
#estados
var muerto: bool = false
var golpeando: bool = false
#Distancia recorrida
var distancia_recorrida: float
var posicion_y_inicial: float

func _ready() -> void:
	await get_tree().process_frame  # Espera 1 frame para que global_position sea válido
	await get_tree().process_frame
	ControladorJuego.referencia_jugador(self)
	#area_daño.body_entered.connect(_on_area_daño_body_entered)
	distancia_recorrida = 0.0
	posicion_y_inicial = global_position.y
	
func _process(_delta: float) -> void:
	await get_tree().process_frame
	
	
func _physics_process(delta: float) -> void:	
	if muerto:
		return
	# gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta
	salto()
	culetazo()
	movimiento_lateral()
	move_and_slide()
	cambio_animacion()
	sumar_distancia_bajada()
	

##-----------------------------Funciones de estado-----------------------------##
func haciendo_culetazo() -> bool:
	return golpeando

func peso_actual() -> int:
	return mochila.n_piedras()

##---------------------------Interacciones escenario---------------------------##
func pasar_piedra_mochila(piedra_recogida) -> void:
	mochila.anadir_piedra(piedra_recogida)

# Golpe contra escenario
func _on_area_daño_body_entered(body: Node2D) -> void:
	if body and body is not Mob:
		#print ("Jugador recibe daño de escenario")
		self.recibe_daño(1)
		rebotar()
##---------------------------Funciones de Movimiento---------------------------##
# Maneja movimiento flechas izquierda y derecha
func movimiento_lateral() -> void:
	if !golpeando:
		if Input.is_action_pressed("derecha"):
			velocity.x = velocidad
		elif Input.is_action_pressed("izquierda"):
			velocity.x = -velocidad
		else:
			velocity.x = move_toward(velocity.x, 0, velocidad)

func salto() -> void:
	if Input.is_action_just_pressed("saltar") and is_on_floor():
		velocity.y = velocidad_salto

func rebotar() -> void:
	velocity.y = velocidad_rebote
	terminar_culetazo()

##-----------------------------Manejo de culetazo-----------------------------##
func culetazo() -> void:
	if(Input.is_action_just_pressed("culetazo") && !is_on_floor() && !golpeando):
		iniciar_culetazo()		
	if golpeando:
		procesar_culetazo()

func iniciar_culetazo() ->void:
	golpeando = true
	altura_inicial_culetazo = position.y
	

func procesar_culetazo()->void:
	velocity.x = 0
	velocity.y = velocidad_culetazo
	
	var distancia_recorrida_culetazo = position.y - altura_inicial_culetazo
	
	if distancia_recorrida_culetazo >= distancia_culetazo:
		terminar_culetazo()
	elif detectar_contacto_culetazo():
		procesar_contacto_culetazo()
	
func terminar_culetazo()-> void:
	golpeando = false
	
func detectar_contacto_culetazo()->bool:
	if get_slide_collision_count() > 0:
		return true
	else:
		return false
	
	
func procesar_contacto_culetazo() ->void:
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var objeto = collision.get_collider()
		#print("Golpee: ", objeto.name)
		
		if objeto.name == 'Enemigo' and  collision.get_normal() == Vector2.UP:
			rebotar()
		else:
			terminar_culetazo()

# Cambia la animación del personaje dependiendo de su estaso
func cambio_animacion() -> void:
	if !is_on_floor() && !golpeando:
		animacion.play("saltar")
	elif !is_on_floor() && golpeando:
		animacion.play("culetazo")
	elif velocity.x != 0:
		animacion.play("correr")
	else:
		animacion.play("idle")
	
	# Cambiar horientación sprite izquierda y derecha	
	if Input.is_action_pressed("derecha"):
		animacion.flip_h = true
	elif Input.is_action_pressed("izquierda"):
		animacion.flip_h = false


##-----------------------------Manejo de daño-----------------------------##
# Función llamada por la clase Mob
func recibe_daño_mob(mob: Mob) -> void:
	if mob:
		recibe_daño(mob.daño)
	else:
		push_error("Mob no válido o null")

# Pierdes piedras igual al daño recibido y si no tienes mueres
func recibe_daño(d:int) -> void:
	if mochila.n_piedras() > 0:
		mochila.perder_piedras(d)
	else:
		muerte()
	
func muerte() -> void:
	print("muerto")
	ControladorJuego.guardar_partida()
	#_muerto = true
	#animacion.stop()

#calcula la distancia total descendida por el personaje
func sumar_distancia_bajada() -> void:
	var pos_y_actual = global_position.y
	var nueva_distancia = pos_y_actual - posicion_y_inicial
	#print("posicion_y_inicial : ", posicion_y_inicial, " pos_y_actual : ", pos_y_actual, " nueva_distancia : ", nueva_distancia) 
	if nueva_distancia > distancia_recorrida:
		distancia_recorrida = nueva_distancia
		ControladorJuego.actualizar_distancia(distancia_recorrida)
		#print("Distancia recorrida: %.2f px" % abs(distancia_recorrida))
