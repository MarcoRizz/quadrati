extends CanvasLayer

enum AttemptResult {
	NEW_FIND, #nuova parola trovata
	WRONG,    #parola sbagliata
	REPEATED, #parola già trovata in precedenza
	BONUS     #parola bonus
}

const http_json_source = "https://script.google.com/macros/s/AKfycby6N9vEbuGpOp5Xn03sroodyP4UGcMLt2qHz2rnV-6AtMLJDodd3TvTnt_gZvTRpic/exec"

const fileName_actual_grid := "user://savejson.save"
const fileName_actual_results := "user://savegame.save"
const fileName_old_grid := "user://lastsavedjson.save"
const fileName_old_results := "user://lastsavedgame.save"

@onready var vbox_obj = $VBox
@onready var game_obj = $VBox/Game
@onready var midText_obj = $MidText
@onready var midText_HideButt = $MidText/HideButton
@onready var title_obj = $VBox/Title
@onready var yesterdayButton_obj = $VBox/Title/YesterdayButton

var todaysJson : Dictionary = {"todaysNum" = 0, "grid" = [], "words" = [], "startingLinks" = [], "passingLinks" = []}
var todaysSave : Dictionary = {"todaysNum" = 0, "wordsFinded" = [], "bonusFinded" = [], "stats" = {}}

var ready_to_play = false # Da quando la imposto true salvo la partita alla chiusura dell'app

func _ready() -> void:
	#leggo il file json di oggi
	# Create an HTTP request node and connect its completion signal.
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_http_request_completed)
	game_obj.hide()
	midText_obj.show()
	
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
		load_todays_data_to_game()


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
			load_todays_data_to_game()
			return
	
	# Ricevo il grid odierno
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
		load_todays_data_to_game()
		return
	
	# Controlla se esiste già un file fileName_actual_grid
	var local_saved_game = load_json_file(fileName_actual_grid)
	if not valid_game_file(local_saved_game) or not local_saved_game.todaysNum == todaysJson.todaysNum:
		if not valid_game_file(local_saved_game):
			if not local_saved_game == {}:
				print("corrupted json file, overwriting it")
		else:
			# Salva una copia del file esistente con il nuovo nome fileName_old_grid
			save_dictionary_file(local_saved_game, fileName_old_grid)
		# Salva il nuovo file json in fileName_actual_grid
		save_dictionary_file(todaysJson, fileName_actual_grid)
	
	# Controlla se il 'todaysNum' del file salvato è diverso (è cambiato giorno)
	if valid_game_file(local_saved_game) and local_saved_game.todaysNum != todaysJson.todaysNum:
		# Salva una copia del file esistente con il nuovo nome fileName_old_grid
		save_dictionary_file(local_saved_game, fileName_old_grid)
		
		# Salva il nuovo file json in fileName_actual_grid
		save_dictionary_file(todaysJson, fileName_actual_grid)
	
	load_todays_data_to_game()


func load_todays_data_to_game():
	# Carico il salvataggio precedente
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
		todaysSave.bonusFinded = []
		todaysSave.stats = {}
	
	# Carico la schermata
	title_obj.text += "#" + str(todaysJson.todaysNum)
	game_obj.load_game(todaysJson)
	game_obj.load_results(todaysSave)
	game_obj.show()
	midText_obj.hide()
	ready_to_play = true


func _notification(what: int) -> void:
	# Se ricevi una notifica di chiusura salvo le stats
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		if ready_to_play and not game_obj.yesterday_mode:
			save_game()


func valid_game_file(file: Dictionary) -> bool:
	return file.has("grid") and file.has("words") and file.has("passingLinks") and file.has("startingLinks") and file.has("todaysNum")


func valid_save_file(file: Dictionary) -> bool:
	return file.has("todaysNum") and file.has("wordsFinded")


func _on_yesterday_button_toggled(toggled_on: bool) -> void:
	midText_obj.hide()
	var game_to_load: Dictionary
	var save_to_load: Dictionary
	var NodeGrid: Resource
	if toggled_on:
		yesterdayButton_obj.rotation = PI
		# Carico i dati vecchi
		game_to_load = load_json_file(fileName_old_grid)
		if not valid_game_file(game_to_load) and not game_to_load == {}:
			#TODO: messaggio a schermo
			print("corrupted old json file, old results view canceled")
			return
		
		# Sono sicuro di procedere, salvo le stats della partita in corso
		save_game()
		
		save_to_load = load_json_file(fileName_old_results)
		if not valid_save_file(save_to_load) or not save_to_load.todaysNum == game_to_load.todaysNum:
			if not valid_save_file(save_to_load) and not save_to_load == {}:
				print("corrupted old save file, ignoring it...")
			save_to_load.clear()
		
		NodeGrid = preload("res://scenes/yesterday_game.tscn")
	else:
		yesterdayButton_obj.rotation = 0
		game_to_load = todaysJson
		save_to_load = todaysSave
		NodeGrid = preload("res://scenes/main_game.tscn")
	
	# Cancello Game vecchio e ne istanzio uno nuovo
	game_obj.free()
	var new_grid = NodeGrid.instantiate()
	vbox_obj.add_child(new_grid)
	game_obj = new_grid
	game_obj.size_flags_vertical = Control.SIZE_EXPAND_FILL #opzione Expand in Container Sizing
	
	title_obj.text = "QUADRATI#" + str(game_to_load.todaysNum)
	game_obj.yesterday_mode = toggled_on
	game_obj.load_game(game_to_load)
	game_obj.load_results(save_to_load)
	if toggled_on:
		game_obj.grid_target_scale = Vector2(0.5, 0.5)
	else:
		game_obj.attempt_result.connect(_on_game_attempt_result)
		game_obj.game_complete.connect(_on_game_game_complete)


func load_json_file(fileName: String) -> Dictionary:
	if not FileAccess.file_exists(fileName):
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
	midText_obj.text = "Complimenti, hai vinto!"
	midText_obj.get_node("Background").self_modulate = Color.SKY_BLUE
	midText_obj.show()
	midText_HideButt.show()


func _on_game_attempt_result(result: AttemptResult, word: String) -> void:
	if result == AttemptResult.NEW_FIND or result == AttemptResult.BONUS:
		if result == AttemptResult.NEW_FIND:
			todaysSave.wordsFinded.append(word)
		elif result == AttemptResult.BONUS:
			todaysSave.bonusFinded.append(word)
		
		save_game()


func _on_hide_button_pressed() -> void:
	midText_obj.hide()


func save_game() -> void:
	todaysSave.stats = game_obj.get_stats()
	save_dictionary_file(todaysSave, fileName_actual_results)
