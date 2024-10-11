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
					var last_label = last_container.get_child(-1)
					if last_label.position.x + last_label.size.x + w_dash_label + font.get_string_size(word).x + 8 > last_container.get_combined_minimum_size().x:
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
			vbox.add_child(lunghezza_parole[size_n]["title"])
			# Aggiungi tutti gli HBoxContainer per la specifica lunghezza di parole
			for container in lunghezza_parole[size_n]["containers"]:
				vbox.add_child(container)
