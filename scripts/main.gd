extends Node2D

const http_json_source = "https://script.google.com/macros/s/AKfycby6N9vEbuGpOp5Xn03sroodyP4UGcMLt2qHz2rnV-6AtMLJDodd3TvTnt_gZvTRpic/exec"

signal attempt_result(word_finded: int, word: String)

var words = [] #colleziono tutte le parole
var words_finded = [] #colleziono le parole trovate

func _ready() -> void:
	#leggo il file json di oggi
	# Create an HTTP request node and connect its completion signal.
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)
	$Grid.hide()
	$Parola.hide()
	$ProgressBar.hide()
	$MidText.show()

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
			words.append(i_parola)
			$ProgressBar.max_value += len(i_parola)
		$Grid.assegna_lettere(json_as_dict)
		$Grid.show()
		$Parola.show()
		$ProgressBar.show()
		$MidText.hide()
	else:
		printerr("NO DATA")
		push_error("NO DATA")
		get_tree().quit()

func _input(event: InputEvent) -> void:
	if event.is_action_released("click"):
		var word_guessed = $Parola.text
		var result
		if words_finded.has(word_guessed):
			result = 2  #parola già trovata
			#todo: messaggio parola ripetuta
		elif words.has(word_guessed):
			result = 1  #parola nuova trovata
			words_finded.append(word_guessed)
		else:
			result = 0  #parola non troata
			#todo: messaggio paroal non trovata
		
		attempt_result.emit(result, $Parola.text)

func _on_progress_bar_FINE() -> void:
	$MidText.text = "Complimenti, hai vinto!"
	var new_sb = StyleBoxFlat.new()
	new_sb.bg_color = Color.WHITE_SMOKE
	$MidText.add_stylebox_override("normal", new_sb)
	$MidText.show()


func _on_progress_bar_over_1_4_signal() -> void:
	$Grid.number_shown = true
