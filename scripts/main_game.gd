extends Control

enum AttemptResult {
	NEW_FIND, #nuova parola trovata
	WRONG,    #parola sbagliata
	REPEATED, #parola già trovata in precedenza
	BONUS     #parola bonus
}

@onready var grid_obj = $VBox/Grid
@onready var grid_gridCont_obj = $VBox/Grid/GridContainer
@onready var display_obj = $VBox/Display
@onready var wordPanel_obj = $VBox/WordPanel
@onready var progressBar_obj = $VBox/ProgressBar
@onready var stats_obj = $VBox/Stats
@onready var panel_bonus_obj: PanelContainer = $VBox/Display/PanelBonus
@onready var button_hint_obj: TextureButton = $VBox/MarginContainer/HBoxLeft/ButtonHint


signal attempt_result(word_finded: AttemptResult, word: String)
signal game_complete()

var yesterday_mode = false

var words: PackedStringArray = [] #colleziono tutte le parole
var startingWords: PackedVector2Array  = [] #colleziono tutti gli inizi delle parole
var bonus: PackedStringArray  = [] #colleziono tutte le parole bonus

var words_finded: PackedStringArray  = [] #colleziono le parole trovate
var bonus_finded: PackedStringArray  = [] #colleziono le parole bonus trovate

var grid_target_scale = Vector2.ONE #serve per l'animazione del dimensionamento
const scaling_vel = 0.5


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not grid_gridCont_obj.scale == grid_target_scale:
		# Se sono in yesterday_mode salto l'animazione
		if yesterday_mode:
			grid_gridCont_obj.scale = grid_target_scale
		
		elif grid_target_scale > grid_gridCont_obj.scale:
			grid_gridCont_obj.scale += Vector2.ONE * delta * scaling_vel
			if grid_gridCont_obj.scale > grid_target_scale:
				grid_gridCont_obj.scale = grid_target_scale
		else:
			grid_gridCont_obj.scale -= Vector2.ONE * delta * scaling_vel
			if grid_gridCont_obj.scale < grid_target_scale:
				grid_gridCont_obj.scale = grid_target_scale
		
		grid_obj.custom_minimum_size = grid_gridCont_obj.size * grid_gridCont_obj.scale
	

func _input(event: InputEvent) -> void:
	if event.is_action_released("click") and grid_obj.is_visible_in_tree(): #TODO: assegnare a Grid?
		if grid_obj.valid_attempt:
			# Elaboro il risulatto
			var word_guessed = display_obj.text
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
			
			var word = display_obj.text
			grid_obj.set_answer(result, word)
			stats_obj.add_attempt(result, word)
			if result == AttemptResult.NEW_FIND:
				wordPanel_obj.add_word(word)
				progressBar_obj.increase(word.length())
			elif result == AttemptResult.BONUS:
				wordPanel_obj.add_bonus(word)
				progressBar_obj.increase_bonus(word.length())
				panel_bonus_obj.show()
			attempt_result.emit(result, word)


func load_game(data: Dictionary):
	if yesterday_mode:
		grid_obj.set_yesterday_mode()
		wordPanel_obj.set_yesterday_mode()
		stats_obj.set_yesterday_mode()
	# Aggiungi le parole
	for i_parola in data.words:
		words.append(i_parola)
		progressBar_obj.increase_max_value(i_parola.length())
	
	# Salvo le posizioni iniziali
	for i_start in data.startingLinks:
		startingWords.append(Vector2(i_start[0], i_start[1]))
	
	# salvo le parole bonus
	if data.has("bonus"):
		for i_parola in data.bonus:
			bonus.append(i_parola)
	
	# Carica le parole odierne
	grid_obj.instantiate(data)
	wordPanel_obj.instantiate(data)


func load_results(save: Dictionary):
	if save.has("wordsFinded"):
		for i_parola in save.wordsFinded:
			words_finded.append(i_parola)
			wordPanel_obj.add_word(i_parola)
			progressBar_obj.increase(i_parola.length())
			grid_obj.set_answer(AttemptResult.NEW_FIND, i_parola)
	
	if save.has("bonusFinded"):
		for i_parola in save.bonusFinded:
			bonus_finded.append(i_parola)
			wordPanel_obj.add_bonus(i_parola)
			progressBar_obj.increase_bonus(i_parola.length())
	
	# Carico le statistiche
	if save.has("stats") and not save["stats"].is_empty():
		stats_obj.set_timer(save.stats.get("timer", 0))
		stats_obj.set_attempts(save.stats.get("attempts_n", 0))
		if not yesterday_mode:
			button_hint_obj.set_hints_left(save.stats.get("hints_left", 3))
	
	# Se sono in yesterday_mode rivelo le rimanenti
	if yesterday_mode:
		wordPanel_obj.reveal_remaining_words()


func _on_wordpanel_show_path(word: String) -> void:
	var path = find_path_from_json(word)
	
	if path == []:
		print("Errore: path non trovato della parola ", word)
		return
	
	grid_obj.show_path(path)
	print("segnale di path emesso, path: ", path)


func find_path_from_json(word: String) -> Array[Vector2]:
	# Cerco l'indice della parola nel json
	var index = words.find(word)
	# Verifica se l'elemento è stato trovato
	if not index == -1:
		var starting_tile = startingWords[index]
		starting_tile = Vector2(starting_tile[0], starting_tile[1]) #converto in Vector2
		var path = find_path_recursive_step([starting_tile], 0, word)
		
		return path
	
	if bonus.has(word):
		# Per le parole bonus non ho startingWords, devo trovarla manualmente
		for x in range(0, 4):
			for y in range(0, 4):
				var path : Array[Vector2] = []
				if grid_obj.tiles[x][y].get_letter() == word[0]:
					path = find_path_recursive_step([Vector2(x, y)], 0, word)
				if not path.is_empty():
					return path
	
	print("Errore: parola ", word, " non trovata nel JSON")
	return []


func find_path_recursive_step(starting_tile: Array[Vector2], step: int, word: String) -> Array[Vector2]:
	# Controllo se abbiamo raggiunto il numero di passi massimo
	if step + 1 == word.length():
		return starting_tile
	
	else:
		for dir in [Vector2(0, -1), Vector2(1, -1), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 0), Vector2(-1, -1)]:
			var new_tile = starting_tile[-1] + dir
			if new_tile.x >= 0 and new_tile.x < 4 and new_tile.y >= 0 and new_tile.y < 4 and starting_tile.find(new_tile) == -1 and grid_obj.tiles[new_tile.x][new_tile.y].get_letter() == word[step + 1]:
				starting_tile.append(new_tile)
				var path = find_path_recursive_step(starting_tile, step + 1, word)
				if path.size() == word.length():
					return path
				starting_tile.resize(starting_tile.size() - 1)
			
	return []


func _on_grid_clear() -> void:
	if progressBar_obj.value >= progressBar_obj.max_value and not grid_obj.yesterday_mode:
		stats_obj.set_process(false)
		game_complete.emit()


func _on_word_panel_expand(expansion_toggle: bool) -> void:
	grid_target_scale = Vector2.ONE * (0.5 if expansion_toggle else 1.0)


func get_stats() -> Dictionary:
	return {"timer" = stats_obj.time, "attempts_n" = stats_obj.attempts_n, "hints_left" = button_hint_obj.hints_left}


func _on_button_hint_pressed() -> void:
	print("Nuovo indizio:")
	# Recupero gli inidizi già mostrati
	var hints_obj_list = grid_obj.get_hints()
	
	# Recupero le parole non ancora trovate
	var words_hidden = Array()
	for word_i in words:
		if not words_finded.has(word_i):
			words_hidden.append(word_i)
	
	# Elaboro un nuovo hint
	while words_hidden.size() > 0:
		var skip = false
		var random_index = randi() % words_hidden.size()
		var random_word = words_hidden[random_index]
		print("random_word: ", random_word)
		
		for hint_i in hints_obj_list:
			if hint_i.word == random_word:
				skip = true
		if skip: # Ho già un indizio associato alla parola prescelta
			words_hidden.erase(random_word)
			print("già pickkata, scarto")
			continue
		
		var random_word_path = find_path_from_json(random_word)
		var new_hint_center = random_word_path[0]
		var new_hint_dir = random_word_path[1] - new_hint_center
		print("new_hint_center: ", new_hint_center, "; new_hint_dir: ", new_hint_dir)
		
		for hint_i in hints_obj_list:
			if hint_i.grid_pos == new_hint_center and hint_i.direction == new_hint_dir:
				skip = true
		if skip: # Ho già un indizio con questa posizione
			words_hidden.erase(random_word)
			print("indizio sovrapposto, scarto")
			continue
		else:
			grid_obj.add_hint(new_hint_center, new_hint_dir, random_word)
			print("indizio aggiunto")
			return
	
	print("Parole disponibili finite")
	return
