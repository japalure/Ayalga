extends Node

func _ready() -> void:
	pass # Replace with function body.

func _process(_delta: float) -> void:
	pass

# Pausar el juego
# Para que funcione debe estar el Process -> Mode en Always
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pausa"):
		get_tree().paused = !get_tree().paused
