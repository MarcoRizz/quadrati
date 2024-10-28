extends Node2D

enum AttemptResult {
	NEW_FIND, #nuova parola trovata
	WRONG, #parola sbagliata
	REPEATED #parola già trovata in precedenza
}

const http_json_source = "https://script.google.com/macros/s/AKfycby6N9vEbuGpOp5Xn03sroodyP4UGcMLt2qHz2rnV-6AtMLJDodd3TvTnt_gZvTRpic/exec"

const fileName_actual_grid := "user://savejson.save"
const fileName_actual_results := "user://savegame.save"
const fileName_old_grid := "user://lastsavedjson.save"
const fileName_old_results := "user://lastsavedgame.save"

var todaysJson : Dictionary
var todaysSave : Dictionary


func _ready() -> void:
	#leggo il file json di oggi
	# Create an HTTP request node and connect its completion signal.
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)
	$Game.hide()
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
		if not FileAccess.file_exists(fileName_actual_grid):
			print("No saved JSON, exiting")
			get_tree().quit()
			return
		var json_as_text = FileAccess.get_file_as_string(fileName_actual_grid)
		todaysJson = JSON.parse_string(json_as_text)
		load_data_to_game(todaysJson)


# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	if not result == 0:
		print("An error occurred in the HTTP request, error " + str(result))
		if FileAccess.file_exists(fileName_actual_grid):
			var json_as_text = FileAccess.get_file_as_string(fileName_actual_grid)
			todaysJson = JSON.parse_string(json_as_text)
			if not valid_game_file(todaysJson):
				print("Saved JSON is corrupted, exiting")
				get_tree().quit()
				return
			load_data_to_game(todaysJson)
			return
	
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	todaysJson = json.get_data()
	
	if not valid_game_file(todaysJson):
		print("JSON not corresponding, load saved JSON")
		if not FileAccess.file_exists(fileName_actual_grid):
			print("No saved JSON, exiting")
			get_tree().quit()
			return
		var json_as_text = FileAccess.get_file_as_string(fileName_actual_grid)
		todaysJson = JSON.parse_string(json_as_text)
		if not valid_game_file(todaysJson):
			print("Saved JSON is corrupted, exiting")
			get_tree().quit()
			return
		load_data_to_game(todaysJson)
		return
	
	# Controlla se esiste già un file fileName_actual_grid
	var local_saved_game = load_json_file(fileName_actual_grid, false)
	
	
	if not valid_game_file(local_saved_game) or not local_saved_game.todaysNum == todaysJson.todaysNum:
		if not valid_game_file(local_saved_game):
			if not local_saved_game == {}:
				print("corrupted json file, overwriting it")
		else:
			# Salva una copia del file esistente con il nuovo nome fileName_old_grid
			save_dictionary_file(local_saved_game, fileName_old_grid)
		# Salva il nuovo file json in fileName_actual_grid
		save_dictionary_file(todaysJson, fileName_actual_grid)
	
	##in rifacimento
	# Controlla se il 'todaysNum' del file salvato è diverso
	if valid_game_file(local_saved_game) and local_saved_game.todaysNum != todaysJson.todaysNum:
		# Salva una copia del file esistente con il nuovo nome fileName_old_grid
		save_dictionary_file(local_saved_game, fileName_old_grid)
		
		# Salva il nuovo file json in fileName_actual_grid
		save_dictionary_file(todaysJson, fileName_actual_grid)
	##in rifacimento
	
	load_data_to_game(todaysJson)


func valid_game_file(file: Dictionary) -> bool:
	return file.has("grid") and file.has("words") and file.has("passingLinks") and file.has("startingLinks") and file.has("todaysNum")


func valid_save_file(file: Dictionary) -> bool:
	return file.has("todaysNum") and file.has("wordsFinded")

func load_data_to_game(json_to_load, also_load_results: bool = true):
	$Title.text += "#" + str(json_to_load.todaysNum)
	
	#trasmetto le informazioni ricevute al Game
	$Game.load_game(json_to_load)
	
	#se trovo un file salvato odierno, carico le parole già trovate
	if also_load_results:
		todaysSave = load_json_file(fileName_actual_results)
		
		if not valid_save_file(todaysSave) or not todaysSave.todaysNum == todaysJson.todaysNum:
			if not valid_save_file(todaysSave):
				if not todaysSave == {}:
					print("corrupted save file, ignoring it...")
			else:
				# Copia il contenuto del file in un nuovo file fileName_old_results
				save_dictionary_file(todaysSave, fileName_old_results)
			#creo un nuovo Dizionario vuoto col numero odierno
			todaysSave.clear()
			todaysSave.todaysNum = todaysJson.todaysNum
			todaysSave.wordsFinded = []
		else:
			$Game.load_results(todaysSave)
	
	$Game.show()
	$MidText.hide()


#func _on_yesterday_button_pressed() -> void:
	#$Grid.history_mode = not $Grid.history_mode
	#var json_directory: String
	#var save_directory: String
	#
	#if $Grid.history_mode:
		#json_directory = fileName_old_grid
		#save_directory = fileName_old_results
	#else:
		#json_directory = fileName_actual_grid
		#save_directory = fileName_actual_results
#
	### CARICO LA GRIGLIA DELLA VOLTA SCORSA ##
	#if not FileAccess.file_exists(json_directory):
		#print("No saved JSON")
		#return
	#
	#var old_json_as_text = FileAccess.get_file_as_string(json_directory)
	#var yesterdaysJson = JSON.parse_string(old_json_as_text)
	#if not valid_game_file(yesterdaysJson):
		#print("Old saved JSON is corrupted")
		#return
		#
	### CARICO I RISULATI DELLA VOLTA SCORSA ##
	#var yesterdaysSave
	#if not FileAccess.file_exists(save_directory):
		#yesterdaysSave = []  # Non esiste un file di salvataggio
#
	## Carica il file di salvataggio come stringa
	#var old_save_as_text = FileAccess.get_file_as_string(save_directory)
	#var parse_old_result = JSON.parse_string(old_save_as_text)
	#
	## Controlla se il parsing ha avuto successo
	#if not parse_old_result.has("wordsFinded"):
		#print("Errore nel parsing del file old_save: ", parse_old_result.error_string)
		#yesterdaysSave = []
	#
	## Se il numero di "today's number" non corrisponde, rinomina il file
	#if parse_old_result.todaysNum != yesterdaysJson.todaysNum:
		#print("Il file old_save non corrisponde con old_JSON")
		#yesterdaysSave = []
	#
	## Se tutto è ok, ritorna le parole trovate
	#yesterdaysSave = parse_old_result.wordsFinded
	#
	### SISTEMO LA GRIGLIA ##
	#$Title.text = "QUADRATI"
	#$ProgressBar.reset()
	#$Grid.deinstantiate()
	#$WordPanel.deinstantiate()
	##$WordPanel.instantiate(yesterdaysJson)
	#if $Grid.history_mode:
		#load_data(yesterdaysJson, false)
		#
		#for parola in yesterdaysSave:
			#attempt_result.emit(1, parola)
		#
		#var words_to_reveal = yesterdaysJson["words"]
		#
		#words_to_reveal = words_to_reveal.filter(func(word):
			#return not yesterdaysSave.has(word))
		#
		#for parola in words_to_reveal:
			#reveal_word.emit(parola)
#
		#$YesterdayButton.rotation = PI
	#else:
		#load_data(yesterdaysJson)
#
		#$YesterdayButton.rotation = 0


func load_json_file(fileName: String, expect_existing_file: bool = true) -> Dictionary:
	if not FileAccess.file_exists(fileName):
		if expect_existing_file:
			print("load_json_file -> file non trovato: ", fileName)
			return {}
		return {}
	
	# Carica il file di salvataggio
	var json_as_text = FileAccess.get_file_as_string(fileName)
	var parse_result = JSON.new()
	var error = parse_result.parse(json_as_text)
	if not error == OK:
		print("load_json_file -> json parse error: ", parse_result.get_error_message(), " in ", json_as_text, " at line ", parse_result.get_error_line())
		return {}
	
	return parse_result.data


func save_dictionary_file(dizionario: Dictionary, file_path: String) -> bool:
	# Apri il file in modalità scrittura
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	
	# Controlla se il file è stato aperto correttamente
	if not file:
		print("Errore: impossibile aprire il file per la scrittura.")
		return false
	
	
	# Salva la stringa JSON nel file
	file.store_string(JSON.stringify(dizionario))
	# Chiudi il file
	file.close()
	return true


func _on_game_game_complete() -> void:
	$MidText.text = "Complimenti, hai vinto!"
	$MidText/Background.self_modulate = Color.SKY_BLUE
	$MidText.show()


func _on_game_attempt_result(word_finded: AttemptResult, word: String) -> void:
	if word_finded == AttemptResult.NEW_FIND:
		todaysSave.wordsFinded.append(word)
		save_dictionary_file(todaysSave, fileName_actual_results)
