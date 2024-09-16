extends Node2D

signal attempt_result(word_finded: bool, word: String)

func _ready() -> void:
	#leggo il file json di oggi
	var file = "res://daily_map.json"
	var json_as_text = FileAccess.get_file_as_string(file)
	var json_as_dict = JSON.parse_string(json_as_text)
	
	#controllo sulla corretta costruzione del file json_as_dict?
	if not json_as_dict.has("today"):
		printerr("NO DATA")
		push_error("NO DATA")
		get_tree().quit()
	else:
		$Grid.assegna_lettere(json_as_dict)

func _input(event: InputEvent) -> void:
	if event.is_action_released("click"):
		var word_finded = false
		if len($Parola.text) > 3:
			word_finded = randi_range(0, 1)
		else:
			print("Parola troppo corta") #todo: da inserire nei messaggi ingame
		attempt_result.emit(word_finded, $Parola.text)
