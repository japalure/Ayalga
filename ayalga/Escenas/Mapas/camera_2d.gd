extends Camera2D
@export var personaje: CharacterBody2D

var puede_bajar: bool = true
@export var distancia_bajada: float = 250.0
@export var suavidad_bajada: float = 1.0

func _ready():
	# Espera un frame para asegurar viewport listo
	pass
	#await get_tree().process_frame

func _process(_delta):
	return
	if not personaje or not puede_bajar:
		return
	
	var viewport_size = get_viewport_rect().size
	var umbral_y = 4 * (viewport_size.y / 5.0)  # 2/3 inferior 
	
	var viewport_transform = get_viewport_transform()  # Transform mundial a pantalla
	var pos_personaje_screen = viewport_transform * personaje.global_position
	
	if pos_personaje_screen.y > umbral_y:
		puede_bajar = false
		var objetivo_y = global_position.y + distancia_bajada

		var tween = create_tween()
		tween.tween_property(self, "global_position:y", objetivo_y, suavidad_bajada)
		await tween.finished
		puede_bajar = true
