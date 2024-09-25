extends Node2D

signal attempt_result(word_finded: bool, word: String)

var remainingWords = [] #colleziono le parole non ancora trovate

func _ready() -> void:
	#leggo il file json di oggi
	var file = "res://quadrati#1.json"
	var json_as_text = FileAccess.get_file_as_string(file)
	var json_as_dict = JSON.parse_string(json_as_text)
	
	#controllo sulla corretta costruzione del file json_as_dict?
	if json_as_dict.has("grid") and json_as_dict.has("words") and json_as_dict.has("passingLinks") and json_as_dict.has("startingLinks"):
		for i_parola in json_as_dict.words:
			remainingWords.append(i_parola)
			$ProgressBar.max_value += len(i_parola)
		$Grid.assegna_lettere(json_as_dict)
	else:
		printerr("NO DATA")
		push_error("NO DATA")
		get_tree().quit()

func _input(event: InputEvent) -> void:
	if event.is_action_released("click"):
		var word_guessed = $Parola.text
		var word_finded = remainingWords.has(word_guessed)
		if word_finded:
			remainingWords.erase(word_guessed);
		else:
			print("Parola troppo corta") #todo: da inserire nei messaggi ingame
		attempt_result.emit(word_finded, $Parola.text)
