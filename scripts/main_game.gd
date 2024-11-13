extends Node2D

enum AttemptResult {
	NEW_FIND, #nuova parola trovata
	WRONG,    #parola sbagliata
	REPEATED, #parola già trovata in precedenza
	BONUS     #parola bonus
}

signal attempt_result(word_finded: AttemptResult, word: String)
signal game_complete()

var yesterday_mode = false

var words = [] #colleziono tutte le parole
var startingWords = [] #colleziono tutti gli inizi delle parole
var bonus = [] #colleziono tutte le parole bonus

var words_finded = [] #colleziono le parole trovate
var bonus_finded = [] #colleziono le parole bonus trovate


func _input(event: InputEvent) -> void:
	if event.is_action_released("click") and $Grid.is_visible_in_tree(): #TODO: assegnare a Grid?
		if $Grid.valid_attempt:
			var word_guessed = $Display.text
			var result : AttemptResult
			if words_finded.has(word_guessed) or bonus_finded.has(word_guessed):
				result = AttemptResult.REPEATED
				#TODO: messaggio parola ripetuta
			elif words.has(word_guessed):
				result = AttemptResult.NEW_FIND
				words_finded.append(word_guessed)
			elif bonus.has(word_guessed):
				result = AttemptResult.BONUS
				bonus_finded.append(word_guessed)
			else:
				result = AttemptResult.WRONG
				#TODO: messaggio paroal non trovata
			
			var word = $Display.text
			$Grid.set_answer(result, word)
			if result == AttemptResult.NEW_FIND:
				$WordPanel.add_word(word)
				$ProgressBar.increase(word)
			elif result == AttemptResult.BONUS:
				$WordPanel.add_bonus(word)
				$ProgressBar.increase_bonus(word)
			attempt_result.emit(result, word)


func load_game(data: Dictionary):
	if yesterday_mode:
		$Grid.set_yesterday_mode()
		$WordPanel.set_yesterday_mode()
	# Aggiungi le parole
	for i_parola in data.words:
		words.append(i_parola)
		$ProgressBar.max_value += i_parola.length()
	
	# Salvo le posizioni iniziali
	for i_start in data.startingLinks:
		startingWords.append(i_start)
	
	# salvo le parole bonus
	if data.has("bonus"):
		for i_parola in data.bonus:
			bonus.append(i_parola)
	
	# Carica le parole odierne
	$Grid.instantiate(data)
	$WordPanel.instantiate(data)


func load_results(save: Dictionary):
	if save.has("wordsFinded"):
		for i_parola in save.wordsFinded:
			words_finded.append(i_parola)
			$WordPanel.add_word(i_parola)
			$ProgressBar.increase(i_parola)
			$Grid.set_answer(AttemptResult.NEW_FIND, i_parola)
	
	if save.has("bonusFinded"):
		for i_parola in save.bonusFinded:
			bonus_finded.append(i_parola)
			$WordPanel.add_bonus(i_parola)
			$ProgressBar.increase_bonus(i_parola)
	
	# Se sono in yesterday_mode rivelo le rimanenti
	if yesterday_mode:
		$WordPanel.reveal_remaining_words()


func _on_wordpanel_show_path(word: String) -> void:
	var path = find_path_from_json(word)
	
	if path == []:
		print("Errore: path non trovato della parola ", word)
		return
	
	$Grid.show_path(path)
	print("segnale di path emesso, path: ", path)


func find_path_from_json(word: String) -> Array[Vector2]:
	#cerco l'indice della parola nel json
	var index = words.find(word)
	# Verifica se l'elemento è stato trovato
	if index == -1:
		print("Errore: parola ", word, " non trovata nel JSON")
		return []
	
	var starting_tile = startingWords[index]
	starting_tile = Vector2(starting_tile[0], starting_tile[1]) #converto in Vector2
	var path = find_path_recursive_step([starting_tile], 0, word)
	
	return path


func find_path_recursive_step(starting_tile: Array[Vector2], step: int, word: String) -> Array[Vector2]:
	# Controllo se abbiamo raggiunto il numero di passi massimo
	if step + 1 == word.length():
		return starting_tile
	
	else:
		for dir in [Vector2(0, -1), Vector2(1, -1), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 0), Vector2(-1, -1)]:
			var new_tile = starting_tile[-1] + dir
			if new_tile.x >= 0 and new_tile.x < 4 and new_tile.y >= 0 and new_tile.y < 4 and starting_tile.find(new_tile) == -1 and $Grid.tiles[new_tile.x][new_tile.y].get_letter() == word[step + 1]:
				starting_tile.append(new_tile)
				var path = find_path_recursive_step(starting_tile, step + 1, word)
				if path.size() == word.length():
					return path
				starting_tile.resize(starting_tile.size() - 1)
			
	return []


func _on_grid_clear() -> void:
	if $ProgressBar.value >= $ProgressBar.max_value and not $Grid.yesterday_mode:
		game_complete.emit()
