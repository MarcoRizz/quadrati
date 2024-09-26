extends Node2D

const http_json_source = "https://script.google.com/macros/s/AKfycby6N9vEbuGpOp5Xn03sroodyP4UGcMLt2qHz2rnV-6AtMLJDodd3TvTnt_gZvTRpic/exec"

signal attempt_result(word_finded: bool, word: String)

var remainingWords = [] #colleziono le parole non ancora trovate

func _ready() -> void:
	#leggo il file json di oggi
	# Create an HTTP request node and connect its completion signal.
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)
	$Grid.hide()
	$Parola.hide()
	$ProgressBar.hide()
	$Caricamento.show()

	# Perform a GET request. The URL below returns JSON as of writing.
	var error = http_request.request(http_json_source)
	if error != OK:
		push_error("An error occurred in the HTTP request.")

# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	
	#var file = "res://quadrati#1.json"
	#var json_as_text = FileAccess.get_file_as_string(file)
	#var json_as_dict = JSON.parse_string(json_as_text)
	var json_as_dict = response;
	
	#controllo sulla corretta costruzione del file json_as_dict?
	if json_as_dict.has("grid") and json_as_dict.has("words") and json_as_dict.has("passingLinks") and json_as_dict.has("startingLinks"):
		for i_parola in json_as_dict.words:
			remainingWords.append(i_parola)
			$ProgressBar.max_value += len(i_parola)
		$Grid.assegna_lettere(json_as_dict)
		$Grid.show()
		$Parola.show()
		$ProgressBar.show()
		$Caricamento.hide()
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
			print("Parola non trovata") #todo: da inserire nei messaggi ingame
		attempt_result.emit(word_finded, $Parola.text)
