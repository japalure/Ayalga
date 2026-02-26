extends Camera2D
#@export var personaje: CharacterBody2D
@export var personaje:CharacterBody2D
var puede_bajar: bool = true
@export var distancia_bajada: float = 250.0
@export var suavidad_bajada: float = 1.0

func _ready():
	pass
	#await get_tree().process_frame

func _process(_delta):
	if not personaje:
		return

	var target_y:float
	#La cámara nunca sube, aunque el personaje salte
	if self.global_position.y < personaje.global_position.y:
		target_y = personaje.global_position.y
		#print (str(target_y))
	else:	  
		target_y = self.global_position.y
		
	var target_pos = Vector2(self.global_position.x, target_y)
	self.global_position = self.global_position.lerp(target_pos, 10.0 * _delta)
