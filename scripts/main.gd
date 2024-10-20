extends Node2D

const http_json_source = "https://script.google.com/macros/s/AKfycby6N9vEbuGpOp5Xn03sroodyP4UGcMLt2qHz2rnV-6AtMLJDodd3TvTnt_gZvTRpic/exec"

signal attempt_result(word_finded: int, word: String)
signal reveal_word(word: String)
signal show_path(tiles: Array[Vector2])

var todaysJson #qui salvo il JSON caricato
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
	$WordPanel.hide()
	$RotateClockwise.hide()
	$RotateCounterClockwise.hide()
	$YesterdayButton.hide()
	$MidText.show()
	
	# Ottieni informazioni del client
	var ip_adress :String
	if OS.has_feature("windows"):
		if OS.has_environment("COMPUTERNAME"):
			ip_adress =  IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),IP.TYPE_IPV4)
	elif OS.has_feature("Android"):
		var ip_addresses = IP.get_local_addresses()
		for ip in ip_addresses:
			# Salta gli indirizzi IP di loopback (localhost)
			if ip != "127.0.0.1":
				ip_adress = ip
	elif OS.has_feature("x11"):
		if OS.has_environment("HOSTNAME"):
			ip_adress =  IP.resolve_hostname(str(OS.get_environment("HOSTNAME")),IP.TYPE_IPV4)
	elif OS.has_feature("OSX"):
		if OS.has_environment("HOSTNAME"):
			ip_adress =  IP.resolve_hostname(str(OS.get_environment("HOSTNAME")),IP.TYPE_IPV4)
	
	var user_agent = OS.get_name()  # Ottiene il nome del sistema operativo
	var user_locale = OS.get_locale()  # Ottiene la localizzazione dell'utente
	
	# Costruisci l'URL con i parametri
	var params = "?userIp=%s&userAgent=%s&userLocale=%s" % [ip_adress, user_agent, user_locale]
	
	# Perform a GET request. The URL below returns JSON as of writing.
	var error = http_request.request(http_json_source + params)
	if error != OK:
		print("An error occurred in the HTTP request.")
		if not FileAccess.file_exists("user://savejson.save"):
			print("No saved JSON, exiting")
			get_tree().quit()
			return
		var json_as_text = FileAccess.get_file_as_string("user://savejson.save")
		todaysJson = JSON.parse_string(json_as_text)
		load_data(todaysJson)


# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	if not result == 0:
		print("An error occurred in the HTTP request, error " + str(result))
		if FileAccess.file_exists("user://savejson.save"):
			var json_as_text = FileAccess.get_file_as_string("user://savejson.save")
			todaysJson = JSON.parse_string(json_as_text)
			if not valid_json(todaysJson):
				print("Saved JSON is corrupted, exiting")
				get_tree().quit()
				return
			load_data(todaysJson)
			return
	
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	todaysJson = json.get_data()
	
	if not valid_json(todaysJson):
		print("JSON not corresponding, load saved JSON")
		if not FileAccess.file_exists("user://savejson.save"):
			print("No saved JSON, exiting")
			get_tree().quit()
			return
		var json_as_text = FileAccess.get_file_as_string("user://savejson.save")
		todaysJson = JSON.parse_string(json_as_text)
		if not valid_json(todaysJson):
			print("Saved JSON is corrupted, exiting")
			get_tree().quit()
			return
		load_data(todaysJson)
		return
	
	save_json(todaysJson)
	load_data(todaysJson)


func valid_json(json_to_validate) -> bool:
	return json_to_validate.has("grid") and json_to_validate.has("words") and json_to_validate.has("passingLinks") and json_to_validate.has("startingLinks") and json_to_validate.has("todaysNum")


func save_json(json_to_save):
	# Controlla se il file 'savejson.save' esiste
	if FileAccess.file_exists("user://savejson.save"):
		# Leggi il file esistente
		var saved_json_as_text = FileAccess.get_file_as_string("user://savejson.save")
		var parse_result = JSON.parse_string(saved_json_as_text)
		
		# Controlla se il parsing ha avuto successo
		if not parse_result == null:
			# Controlla se il 'todaysNum' del file salvato è diverso
			if parse_result.has("todaysNum") and parse_result.todaysNum != json_to_save.todaysNum:
				# Salva una copia del file esistente con il nuovo nome 'lastsavedjson.save'
				var previous_file = FileAccess.open("user://lastsavedjson.save", FileAccess.WRITE)
				previous_file.store_string(saved_json_as_text)
				previous_file.close()
	
	# Salva il nuovo file json
	var save_file = FileAccess.open("user://savejson.save", FileAccess.WRITE)
	save_file.store_line(JSON.stringify(json_to_save))
	save_file.close()


func load_data(json_to_load, load_word_finded: bool = true):
	$Title.text += "#" + str(json_to_load.todaysNum)
	
	# Aggiungi le parole
	for i_parola in json_to_load.words:
		words.append(i_parola)
		$ProgressBar.max_value += len(i_parola)
	
	# Carica le parole odierne
	$Grid.instantiate(json_to_load)
	$WordPanel.instantiate(json_to_load)
	
	#se trovo un file salvato odierno, carico le parole già trovate
	if load_word_finded:
		words_finded = load_results()
		for i_parola in words_finded:
			attempt_result.emit(1, i_parola)
	
	$Grid.show()
	$Parola.show()
	$ProgressBar.show()
	$WordPanel.show()
	$RotateClockwise.show()
	$RotateCounterClockwise.show()
	$YesterdayButton.show()
	$MidText.hide()


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
	if $ProgressBar.value >= $ProgressBar.max_value and not $Grid.history_mode:
		FINE()


func FINE() -> void:
	$MidText.text = "Complimenti, hai vinto!"
	$MidText/Background.self_modulate = Color.SKY_BLUE
	$MidText.show()


func _on_progress_bar_initials_threshold_signal() -> void:
	$Grid.number_shown = true


func save_results():
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var save_dict = {"todaysNum" = todaysJson.todaysNum, "wordsFinded" = words_finded}
	var json_string = JSON.stringify(save_dict)
	save_file.store_line(json_string)


func load_results() -> Array[String]:
	if not FileAccess.file_exists("user://savegame.save"):
		return []  # Non esiste un file di salvataggio, ritorna un array vuoto.

	# Carica il file di salvataggio come stringa
	var json_as_text = FileAccess.get_file_as_string("user://savegame.save")
	var parse_result = JSON.parse_string(json_as_text)
	
	# Controlla se il parsing ha avuto successo
	if parse_result == null:
		print("Errore nel parsing del file JSON: ", parse_result.error_string)
		return []  # Ritorna un array vuoto in caso di errore
	
	# Se il numero di "today's number" non corrisponde, rinomina il file
	if parse_result.todaysNum != todaysJson.todaysNum:
		# Copia il contenuto del file in un nuovo file "lastsavedgame.save"
		var save_file = FileAccess.open("user://lastsavedgame.save", FileAccess.WRITE)
		save_file.store_string(json_as_text)
		save_file.close()
		
		return []  # Ritorna un array vuoto poiché il numero non corrisponde
	
	var array_strings: Array[String]
	array_strings.assign(parse_result.wordsFinded)
	# Se tutto è ok, ritorna le parole trovate
	return array_strings


func _on_wordpanel_show_path(word: String) -> void:
	var path = find_path_from_json(word)
	
	if path == []:
		print("Errore: path non trovato della parola ", word)
		return
	
	show_path.emit(path)
	print("segnale di path emesso, path: ", path)


func find_path_from_json(word: String) -> Array[Vector2]:
	
	var json_to_check
	if $Grid.history_mode:
		if not FileAccess.file_exists("user://lastsavedjson.save"):
			print("No saved JSON")
			return []
		
		var old_json_as_text = FileAccess.get_file_as_string("user://lastsavedjson.save")
		json_to_check = JSON.parse_string(old_json_as_text)
	else:
		json_to_check = todaysJson
		
	#cerco l'indice della parola nel json
	var index = json_to_check.words.find(word)
	# Verifica se l'elemento è stato trovato
	if index == -1:
		print("Errore: parola ", word, " non trovata nel JSON")
		return []
	
	var starting_tile = json_to_check.startingLinks[index]
	starting_tile = Vector2(starting_tile[0], starting_tile[1]) #converto in Vector2
	var dim_x = json_to_check.grid.size()
	var dim_y = json_to_check.grid[0].size()
	var path = find_path_recursive_step([starting_tile], 0, word, dim_x, dim_y, json_to_check)
	
	return path


func find_path_recursive_step(starting_tile: Array[Vector2], step: int, word: String, dim_x: int, dim_y: int, json_to_check: Dictionary) -> Array[Vector2]:
	# Controllo se abbiamo raggiunto il numero di passi massimo
	if step + 1 == len(word):
		return starting_tile
	
	else:
		for dir in [Vector2(0, -1), Vector2(1, -1), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 0), Vector2(-1, -1)]:
			var new_tile = starting_tile[-1] + dir
			if new_tile.x >= 0 and new_tile.x < dim_x and new_tile.y >= 0 and new_tile.y < dim_y and starting_tile.find(new_tile) == -1 and json_to_check.grid[new_tile.x][new_tile.y] == word[step + 1]:
				starting_tile.append(new_tile)
				var path = find_path_recursive_step(starting_tile, step + 1, word, dim_x, dim_y, json_to_check)
				if len(path) == len(word):
					return path
				starting_tile.resize(starting_tile.size() - 1)
			
	return []


func _on_yesterday_button_pressed() -> void:
	$Grid.history_mode = not $Grid.history_mode
	var json_directory: String
	var save_directory: String
	
	if $Grid.history_mode:
		json_directory = "user://lastsavedjson.save"
		save_directory = "user://lastsavedgame.save"
	else:
		json_directory = "user://savejson.save"
		save_directory = "user://savegame.save"

	## CARICO LA GRIGLIA DELLA VOLTA SCORSA ##
	if not FileAccess.file_exists(json_directory):
		print("No saved JSON")
		return
	
	var old_json_as_text = FileAccess.get_file_as_string(json_directory)
	var yesterdaysJson = JSON.parse_string(old_json_as_text)
	if not valid_json(yesterdaysJson):
		print("Old saved JSON is corrupted")
		return
		
	## CARICO I RISULATI DELLA VOLTA SCORSA ##
	var yesterdaysSave
	if not FileAccess.file_exists(save_directory):
		yesterdaysSave = []  # Non esiste un file di salvataggio

	# Carica il file di salvataggio come stringa
	var old_save_as_text = FileAccess.get_file_as_string(save_directory)
	var parse_old_result = JSON.parse_string(old_save_as_text)
	
	# Controlla se il parsing ha avuto successo
	if not parse_old_result.has("wordsFinded"):
		print("Errore nel parsing del file old_save: ", parse_old_result.error_string)
		yesterdaysSave = []
	
	# Se il numero di "today's number" non corrisponde, rinomina il file
	if parse_old_result.todaysNum != yesterdaysJson.todaysNum:
		print("Il file old_save non corrisponde con old_JSON")
		yesterdaysSave = []
	
	# Se tutto è ok, ritorna le parole trovate
	yesterdaysSave = parse_old_result.wordsFinded
	
	## SISTEMO LA GRIGLIA ##
	$Title.text = "QUADRATI"
	$ProgressBar.max_value = 0
	$ProgressBar.value = 0
	$Grid.deinstantiate()
	$WordPanel.deinstantiate()
	#$WordPanel.instantiate(yesterdaysJson)
	if $Grid.history_mode:
		load_data(yesterdaysJson, false)
		
		for parola in yesterdaysSave:
			attempt_result.emit(1, parola)
		
		var words_to_reveal = yesterdaysJson["words"]
		
		words_to_reveal = words_to_reveal.filter(func(word):
			return not yesterdaysSave.has(word))
		
		for parola in words_to_reveal:
			reveal_word.emit(parola)

		$YesterdayButton.rotation = PI
	else:
		load_data(yesterdaysJson)

		$YesterdayButton.rotation = 0
