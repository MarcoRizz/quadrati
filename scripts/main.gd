extends Node2D

signal attempt_result(word_finded: bool, word: String)

func _ready() -> void:
	#leggo il file json di oggi
	var file = "res://daily_map.json"
	var json_as_text = FileAccess.get_file_as_string(file)
	var json_as_dict = JSON.parse_string(json_as_text)
	
	#controllo sulla corretta costruzione del file json_as_dict?
	if json_as_dict == null:
		printerr("NO DATA")
	else:
		$Grid.assegna_lettere(json_as_dict)

func _input(event: InputEvent) -> void:
	if event.is_action_released("click"):
		attempt_result.emit(true, $Parola.text)
