extends Node2D

const http_json_source = "https://script.google.com/macros/s/AKfycby6N9vEbuGpOp5Xn03sroodyP4UGcMLt2qHz2rnV-6AtMLJDodd3TvTnt_gZvTRpic/exec"

signal attempt_result(word_finded: int, word: String)

var todaysNum  #todo: qui salvo il numero di file JSON caricato
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
	$Panel.hide()
	$RotateClockwise.hide()
	$RotateCounterClockwise.hide()
	$MidText.show()
	
	# Ottieni informazioni del client
	var ip_adress :String
	if OS.has_feature("windows"):
		if OS.has_environment("COMPUTERNAME"):
			ip_adress =  IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),1)
	elif OS.has_feature("Android"):
		var ip_addresses = IP.get_local_addresses()
		for ip in ip_addresses:
			# Salta gli indirizzi IP di loopback (localhost)
			if ip != "127.0.0.1":
				ip_adress = ip
	elif OS.has_feature("x11"):
		if OS.has_environment("HOSTNAME"):
			ip_adress =  IP.resolve_hostname(str(OS.get_environment("HOSTNAME")),1)
	elif OS.has_feature("OSX"):
		if OS.has_environment("HOSTNAME"):
			ip_adress =  IP.resolve_hostname(str(OS.get_environment("HOSTNAME")),1)
	
	var user_agent = OS.get_name()  # Ottiene il nome del sistema operativo
	var user_locale = OS.get_locale()  # Ottiene la localizzazione dell'utente
	
	# Costruisci l'URL con i parametri
	var params = "?userIp=%s&userAgent=%s&userLocale=%s" % [ip_adress, user_agent, user_locale]
	
	# Perform a GET request. The URL below returns JSON as of writing.
	var error = http_request.request(http_json_source + params)
	if error != OK:
		print("An error occurred in the HTTP request.")
		if FileAccess.file_exists("user://savejson.save"):
			var json_as_text = FileAccess.get_file_as_string("user://savejson.save")
			var json_as_dict = JSON.parse_string(json_as_text)
			load_data(json_as_dict, false)

# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	if result == 0:
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var json_as_dict = json.get_data()
		load_data(json_as_dict, true)
	else:
		print("An error occurred in the HTTP request, error " + str(result))
		if FileAccess.file_exists("user://savejson.save"):
			var json_as_text = FileAccess.get_file_as_string("user://savejson.save")
			var json2_as_dict = JSON.parse_string(json_as_text)
			load_data(json2_as_dict, false)
	
	
func load_data(json_as_dict, willSave):
	#controllo sulla corretta costruzione del file json_as_dict?
	if json_as_dict.has("grid") and json_as_dict.has("words") and json_as_dict.has("passingLinks") and json_as_dict.has("startingLinks") and json_as_dict.has("todaysNum"):
		if willSave:
			#salvo il json in locale
			var save_file = FileAccess.open("user://savejson.save", FileAccess.WRITE)
			save_file.store_line(JSON.stringify(json_as_dict))
		
		todaysNum = json_as_dict.todaysNum
		for i_parola in json_as_dict.words:
			words.append(i_parola)
			$ProgressBar.max_value += len(i_parola)
		
		#carico le parole odierne
		$Grid.assegna_lettere(json_as_dict)
		$Panel.assegna_lettere(json_as_dict)
		$Panel.display()
		
		#se trovo un file salvato odierno, carico le parole già trovate
		words_finded = load_results()
		for i_parola in words_finded:
			attempt_result.emit(1, i_parola)
		
		$Grid.show()
		$Parola.show()
		$ProgressBar.show()
		$Panel.show()
		$RotateClockwise.show()
		$RotateCounterClockwise.show()
		$MidText.hide()
	else:
		printerr("NO DATA")
		push_error("NO DATA")
		get_tree().quit()

func _input(event: InputEvent) -> void:
	if event.is_action_released("click") and $Grid.is_visible_in_tree():
		if $Grid.valid_attempt:
			var word_guessed = $Parola.text
			var result
			if words_finded.has(word_guessed):
				result = 2  #parola già trovata
				#todo: messaggio parola ripetuta
			elif words.has(word_guessed):
				result = 1  #parola nuova trovata
				words_finded.append(word_guessed)
				
				save_results()
			else:
				result = 0  #parola non troata
				#todo: messaggio paroal non trovata
			
			attempt_result.emit(result, $Parola.text)
		else:
			$Grid._on_timer_timeout()  #se non era un tentativo valido anticipo il reset della griglia

func _on_grid_clear_grid() -> void:
	if $ProgressBar.value >= $ProgressBar.max_value:
		FINE()

func FINE() -> void:
	$MidText.text = "Complimenti, hai vinto!"
	$MidText/Background.self_modulate = Color.SKY_BLUE
	$MidText.show()


func _on_progress_bar_initials_threshold_signal() -> void:
	$Grid.number_shown = true

func save_results():
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var save_dict = {"todaysNum" = todaysNum, "wordsFinded" = words_finded}
	var json_string = JSON.stringify(save_dict)
	save_file.store_line(json_string)

func load_results() -> Array:
	if not FileAccess.file_exists("user://savegame.save"):
		return [] # Error! We don't have a save to load.
	var json_as_text = FileAccess.get_file_as_string("user://savegame.save")
	var json_as_dict = JSON.parse_string(json_as_text)
	if json_as_dict.todaysNum == todaysNum:
		return json_as_dict.wordsFinded
	else:
		return []
