extends Panel

@onready var vbox = $ScrollContainer/VBoxContainer
@onready var scroll_container = $ScrollContainer

var lunghezza_parole = {
	"4-lettere": {"n": 0, "n_max": 0, "title": Label.new(), "label": Label.new()},
	"5-lettere": {"n": 0, "n_max": 0, "title": Label.new(), "label": Label.new()},
	"6-lettere": {"n": 0, "n_max": 0, "title": Label.new(), "label": Label.new()},
	"7-lettere": {"n": 0, "n_max": 0, "title": Label.new(), "label": Label.new()},
	"8-lettere": {"n": 0, "n_max": 0, "title": Label.new(), "label": Label.new()},
	"9-lettere": {"n": 0, "n_max": 0, "title": Label.new(), "label": Label.new()},
	"10-lettere": {"n": 0, "n_max": 0, "title": Label.new(), "label": Label.new()},
	"11-lettere": {"n": 0, "n_max": 0, "title": Label.new(), "label": Label.new()},
	"12-lettere": {"n": 0, "n_max": 0, "title": Label.new(), "label": Label.new()},
	"13-lettere": {"n": 0, "n_max": 0, "title": Label.new(), "label": Label.new()},
	"14-lettere": {"n": 0, "n_max": 0, "title": Label.new(), "label": Label.new()},
	"15-lettere": {"n": 0, "n_max": 0, "title": Label.new(), "label": Label.new()},
	"16-lettere": {"n": 0, "n_max": 0, "title": Label.new(), "label": Label.new()}
}

func _ready() -> void:
	# Imposta la larghezza massima per i label in base alla larghezza dello ScrollContainer
	var max_width = $ScrollContainer.size.x
	for size in lunghezza_parole.keys():
		lunghezza_parole[size]["title"].set("theme_override_colors/font_color", Color.BLANCHED_ALMOND)
		lunghezza_parole[size]["label"].custom_minimum_size.x = max_width

func _on_main_attempt_result(word_finded: int, word: String) -> void:
	var lunghezza = word.length()
	
	if word_finded == 1:
		# Verifica la chiave corrispondente alla lunghezza della parola
		for chiave in lunghezza_parole:
			if str(lunghezza) + "-lettere" == chiave:
				var current_label = lunghezza_parole[chiave]["label"]
				var current_text = current_label.text

				# Suddividi il testo già presente in righe
				var lines = current_text.split("\n")
				var last_line = lines[-1] if lines.size() > 0 else ""
				
				# Misura la larghezza della riga attuale con la nuova parola
				var new_text = last_line + ("" if last_line == "" else " - ") + word
				
				# Ottieni il font del Label (assicurati che sia definito un font, altrimenti usa il font di default)
				var font = current_label.get_theme_font("font")  # recupera il font dal tema
				if font == null:
					font = current_label.get_font("CustomFont")  # prova a ottenere il font personalizzato se esiste
				
				var new_text_width = font.get_string_size(new_text).x  # calcola la larghezza del testo

				# Se la nuova parola non ci sta nella riga attuale, vai a capo
				if new_text_width > current_label.custom_minimum_size.x:
					lines.append(word)  # Vai a capo e aggiungi la parola senza trattino
				else:
					lines[-1] = new_text  # Aggiorna l'ultima riga con la nuova parola e il trattino

				# Unisci le righe in una singola stringa con "\n"
				current_label.text = String("\n").join(lines)  # Usa String().join() per unire l'Array

				# Aggiorna il conteggio delle parole trovate
				var n = lunghezza_parole[chiave]["n"]
				var n_max = lunghezza_parole[chiave]["n_max"]
				lunghezza_parole[chiave]["n"] = ++n
				lunghezza_parole[chiave]["title"].text = chiave + ": " + str(n) + "/" + str(n_max)
				if n >= n_max:
					lunghezza_parole[size]["title"].set("theme_override_colors/font_color", Color.AQUAMARINE)

func assegna_lettere(json_data) -> void:
	for i_parola in json_data.words:
		var lunghezza = i_parola.length()
		lunghezza_parole[str(lunghezza) + "-lettere"].n_max += 1

func display() -> void:
	var keys_to_remove = []
	
	for size in lunghezza_parole.keys():
		if lunghezza_parole[size]["n_max"] == 0:
			keys_to_remove.append(size)
		else:
			lunghezza_parole[size]["title"].text = size + ": " + str(lunghezza_parole[size]["n"]) + "/" + str(lunghezza_parole[size]["n_max"])
			vbox.add_child(lunghezza_parole[size]["title"])
			vbox.add_child(lunghezza_parole[size]["label"])
	
	for key in keys_to_remove:
		lunghezza_parole.erase(key)
