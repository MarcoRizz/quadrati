extends Panel

@onready var vbox = $ScrollContainer/VBoxContainer
@onready var scroll_container = $ScrollContainer

var lunghezza_parole = {
	"4-lettere": {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	"5-lettere": {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	"6-lettere": {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	"7-lettere": {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	"8-lettere": {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	"9-lettere": {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	"10-lettere": {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	"11-lettere": {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	"12-lettere": {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	"13-lettere": {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	"14-lettere": {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	"15-lettere": {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	"16-lettere": {"n": 0, "n_max": 0, "title": Label.new(), "containers": []}
}

var tween
var last_size_was_original = true
# Dimensioni originali e estese del Panel
var original_size = Vector2(377, 117)
var extended_size = Vector2(377, 350)
var original_position = Vector2(10, 490)
var extended_position = Vector2(10, 490 - (extended_size.y - original_size.y))

var font #salvo il font per calcolare le lunghezze delle stringhe
var h_label
var w_container
var dash_string = "-"
var w_dash_label

func _ready() -> void:
	#imposto le variabili statiche
	# Ottieni il font del Label (assicurati che sia definito un font, altrimenti usa il font di default)
	font = Label.new().get_theme_font("font")  # Recupera il font dal tema
	if font == null:
		font = Label.new().get_font("CustomFont")  # Prova a ottenere il font personalizzato se esiste
	h_label = font.get_string_size(dash_string).y
	w_container = scroll_container.size.x
	w_dash_label = font.get_string_size(dash_string).x
	
	# Impostazioni dei Nodi di lunghezza_parole
	for size_n in lunghezza_parole.keys():
		lunghezza_parole[size_n]["title"].set("theme_override_colors/font_color", Color.BLANCHED_ALMOND)
		# Aggiungi il primo HBoxContainer vuoto
		var hbox = HBoxContainer.new()
		hbox.custom_minimum_size.x = w_container
		hbox.custom_minimum_size.y = h_label
		lunghezza_parole[size_n]["containers"].append(hbox)
	
func _on_main_attempt_result(word_finded: int, word: String) -> void:
	var lunghezza = word.length()
	
	if word_finded == 1:
		# Verifica la size_n corrispondente alla lunghezza della parola
		for size_n in lunghezza_parole:
			if str(lunghezza) + "-lettere" == size_n:
				var n = lunghezza_parole[size_n]["n"]
				var n_max = lunghezza_parole[size_n]["n_max"]
				var current_containers = lunghezza_parole[size_n]["containers"]
				var last_container = current_containers[-1]  # Ottieni l'ultimo HBoxContainer

				# Crea un nuovo Label per la parola
				var word_label = Label.new()
				word_label.text = word
				
				if n > 0:
					# Se la nuova parola non ci sta nell'ultimo container, crea un nuovo HBoxContainer (vai a capo)
					#var last_label = last_container.get_child(-1)
					var x_pos = 0
					for each_label in last_container.get_children():
						x_pos += font.get_string_size(each_label.text).x + 4
						
					if x_pos + w_dash_label + font.get_string_size(word).x + 8 > last_container.get_combined_minimum_size().x: #last_label.position.x + last_label.size.x + w_dash_label + font.get_string_size(word).x + 8 > last_container.get_combined_minimum_size().x:
						var new_container = HBoxContainer.new()
						new_container.custom_minimum_size.x = w_container
						new_container.custom_minimum_size.y = h_label
						current_containers.append(new_container)
						last_container.add_sibling(new_container)
						last_container = new_container
					else:
						# Aggiungi il trattino "-" se non è la prima parola nel container
						var dash_label = Label.new()
						dash_label.text = dash_string
						last_container.add_child(dash_label)
				
				# Aggiungi la parola all'ultimo HBoxContainer
				last_container.add_child(word_label)

				# Aggiorna il conteggio delle parole trovate
				n +=1
				lunghezza_parole[size_n]["n"] = n
				lunghezza_parole[size_n]["title"].text = size_n + ": " + str(n) + "/" + str(n_max)
				if n >= n_max:
					lunghezza_parole[size_n]["title"].set("theme_override_colors/font_color", Color.AQUAMARINE)

func instantiate(json_data) -> void:
	for i_parola in json_data.words:
		var lunghezza = i_parola.length()
		lunghezza_parole[str(lunghezza) + "-lettere"].n_max += 1
	
	for size_n in lunghezza_parole.keys():
		if lunghezza_parole[size_n]["n_max"] == 0:
			lunghezza_parole.erase(size_n)
		else:
			lunghezza_parole[size_n]["title"].text = size_n + ": 0/" + str(lunghezza_parole[size_n]["n_max"])
			vbox.add_child(lunghezza_parole[size_n]["title"])
			
			# Aggiungi tutti gli HBoxContainer per la specifica lunghezza di parole
			for container in lunghezza_parole[size_n]["containers"]:
				vbox.add_child(container)


func _on_button_pressed() -> void:
	if tween:
		tween.kill()
	tween = create_tween().set_parallel(true)
	if self.size == original_size:
		tween.tween_property(self, "size", extended_size, 0.5)#.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(self, "position", extended_position, 0.5)#.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		tween.finished.connect(self._on_tween_end)
	else:
		tween.tween_property(self, "size", original_size, 0.5)#.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(self, "position", original_position, 0.5)#.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		tween.finished.connect(self._on_tween_end)

	# Gestisci i clic fuori dal Panel
func _input(event):
	if self.size == extended_size and event.is_action_pressed("click"):
		# Controlla se il clic è avvenuto fuori dal Panel
		var mouse_pos = get_global_mouse_position()
		var panel_rect = Rect2(global_position, self.size)
		# Usa la trasformazione globale per verificare la posizione del mouse rispetto al Button
		var button_global_transform = $Button.get_global_transform()
		var button_rect = Rect2(button_global_transform.origin, $Button.size)

		if not panel_rect.has_point(mouse_pos) and not button_rect.has_point(mouse_pos):
			if tween:
				tween.kill()
			tween = create_tween().set_parallel(true)
			tween.tween_property(self, "size", original_size, 0.5)#.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(self, "position", original_position, 0.5)#.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
			tween.finished.connect(self._on_tween_end)

func _on_tween_end():
	if last_size_was_original:
		self.size = extended_size
		$Button.rotation = PI
	else:
		self.size = original_size
		$Button.rotation = 0
	last_size_was_original = not last_size_was_original
