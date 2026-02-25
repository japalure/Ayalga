extends CharacterBody2D

@export var animacion: AnimatedSprite2D
@export var area_daño: Area2D
@export var raycast_suelo: RayCast2D


#movimiento
const _velocidad:float = 300.0
const _velocidad_salto:float = -600.0
var _tiempo_en_aire: float = 0.0;
#culetazo
var _altura_inicial_culetazo: float = 0.0
const _distancia_culetazo:float = 200.0
const _velocidad_culetazo:float = 300.0
#estados
var _muerto: bool = false
var _golpeando: bool = false
#Distancia recorrida
var distancia_recorrida: float = 0.0
var posicion_y_inicial: float

func _ready() -> void:
	await get_tree().process_frame  # Espera 1 frame para que global_position sea válido
	await get_tree().process_frame
	area_daño.body_entered.connect(_on_area_daño_body_entered)
	posicion_y_inicial = global_position.y

	
func _physics_process(delta: float) -> void:	
	if _muerto:
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
	
#calcula la distancia total descendida por el personaje
func sumar_distancia_bajada() -> void:
	var pos_y_actual = global_position.y
	var nueva_distancia = pos_y_actual - posicion_y_inicial   # Positiva al bajar
	#print("posicion_y_inicial : ", posicion_y_inicial, " pos_y_actual : ", pos_y_actual, " nueva_distancia : ", nueva_distancia) 
	if nueva_distancia > distancia_recorrida:
		distancia_recorrida = nueva_distancia
		ControladorJuego.actualizar_distancia(distancia_recorrida)
		#print("Distancia recorrida: %.2f px" % abs(distancia_recorrida))


# Maneja movimiento flechas izquierda y derecha
func movimiento_lateral() -> void:
	if !_golpeando:
		if Input.is_action_pressed("derecha"):
			velocity.x = _velocidad
		elif Input.is_action_pressed("izquierda"):
			velocity.x = -_velocidad
		else:
			velocity.x = move_toward(velocity.x, 0, _velocidad)


# Manejo de salto
func salto() -> void:
	
	if Input.is_action_just_pressed("saltar") and is_on_floor():
		velocity.y = _velocidad_salto
		
		

#Manejo culetazo
func culetazo() -> void:
	if(Input.is_action_just_pressed("culetazo") && !is_on_floor() && !_golpeando):
		iniciar_culetazo()		
		
	if _golpeando:
		procesar_culetazo()

func iniciar_culetazo() ->void:
	_golpeando = true
	_altura_inicial_culetazo = position.y
	

func procesar_culetazo()->void:
	velocity.x = 0
	velocity.y = _velocidad_culetazo
	
	var distancia_recorrida_culetazo = position.y - _altura_inicial_culetazo
	
	if distancia_recorrida_culetazo >= _distancia_culetazo:
		terminar_culetazo()
	elif detectar_contacto_culetazo():
		procesar_contacto_culetazo()
	
func terminar_culetazo()-> void:
	_golpeando = false
	
	
	
func detectar_contacto_culetazo()->bool:
	if get_slide_collision_count() > 0:
		return true
	else:
		return false
	
	
func procesar_contacto_culetazo() ->void:
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var objeto = collision.get_collider()
		print("Golpee: ", objeto.name)
		
		if objeto.name == 'Enemigo':
			if collision.get_normal() == Vector2.UP:
				print("Golpee: ", objeto.name)
				velocity.y = -300 # rebote
				terminar_culetazo()
		else:
			terminar_culetazo()

# Cambia la animación del personaje dependiendo de su estaso
func cambio_animacion() -> void:
	if !is_on_floor() && !_golpeando:
		animacion.play("saltar")
	elif !is_on_floor() && _golpeando:
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


func _on_area_daño_body_entered(_body: Node2D) -> void:
	muerte()

func muerte() -> void:
	print("muerto")
	_muerto = true
	animacion.stop()
