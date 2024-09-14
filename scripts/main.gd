extends Node2D

signal attempt_result(word_finded: bool, word: String)

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_released("click"):
		attempt_result.emit(true, $Parola.text)
