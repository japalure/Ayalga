extends CharacterBody2D

@export var animacion: AnimatedSprite2D
@export var area_daño: Area2D

const _velocidad:float = 300.0
const _velocidad_salto:float = -400.0
var _muerto: bool = false

func _ready() -> void:
	area_daño.body_entered.connect(_on_area_daño_body_entered)
	
func _physics_process(delta: float) -> void:
	if _muerto:
		return
	# gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

	salto()
	movimiento_lateral()
	move_and_slide()
	cambio_animacion()

# Manejo de salto
func salto() -> void:
	if Input.is_action_just_pressed("saltar") and is_on_floor():
		velocity.y = _velocidad_salto

# Maneja movimiento flechas izquierda y derecha
func movimiento_lateral() -> void:
	if Input.is_action_pressed("derecha"):
		velocity.x = _velocidad
	elif Input.is_action_pressed("izquierda"):
		velocity.x = -_velocidad
	else:
		velocity.x = move_toward(velocity.x, 0, _velocidad)

# Cambia la animación del personaje dependiendo de su estaso
func cambio_animacion() -> void:
	if !is_on_floor():
		animacion.play("saltar")
	elif velocity.x != 0:
		animacion.play("correr")
	else:
		animacion.play("idle")
	
	# Cambiar horientación sprite izquierda y derecha	
	if Input.is_action_pressed("derecha"):
		animacion.flip_h = true
	elif Input.is_action_pressed("izquierda"):
		animacion.flip_h = false


func _on_area_daño_body_entered(body: Node2D) -> void:
	muerte()

func muerte() -> void:
	print("muerto")
	_muerto = true
	animacion.stop()
