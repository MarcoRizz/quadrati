extends Panel

@onready var vbox = $ScrollContainer/VBoxContainer;

var lunghezza_parole = {"4-size": {"n": 0, "n_max": 0, "title": Label.new(), "label": Label.new()},
						"5-size": {"n": 0, "n_max": 0, "title": Label.new(), "label": Label.new()},
						"6-size": {"n": 0, "n_max": 0, "title": Label.new(), "label": Label.new()},
						"7-size": {"n": 0, "n_max": 0, "title": Label.new(), "label": Label.new()},
						"8-size": {"n": 0, "n_max": 0, "title": Label.new(), "label": Label.new()},
						"9-size": {"n": 0, "n_max": 0, "title": Label.new(), "label": Label.new()},
						"10-size": {"n": 0, "n_max": 0, "title": Label.new(), "label": Label.new()},
						"11-size": {"n": 0, "n_max": 0, "title": Label.new(), "label": Label.new()},
						"12-size": {"n": 0, "n_max": 0, "title": Label.new(), "label": Label.new()},
						"13-size": {"n": 0, "n_max": 0, "title": Label.new(), "label": Label.new()},
						"14-size": {"n": 0, "n_max": 0, "title": Label.new(), "label": Label.new()},
						"15-size": {"n": 0, "n_max": 0, "title": Label.new(), "label": Label.new()},
						"16-size": {"n": 0, "n_max": 0, "title": Label.new(), "label": Label.new()}}
						
var title = []
var label = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_main_attempt_result(word_finded: int, word: String) -> void:
	if word_finded == 1:  #parola nuova trovata
		var lunghezza = word.length()
		for chiave in lunghezza_parole:
			if str(lunghezza) + "-size" == chiave:
				if lunghezza_parole[chiave]["n"] != 0:
					lunghezza_parole[chiave]["label"].text += "-"
				lunghezza_parole[chiave]["label"].text += word
				lunghezza_parole[chiave]["n"] += 1
				lunghezza_parole[chiave]["title"].text = chiave + ": " + str(lunghezza_parole[chiave]["n"]) + "/" + str(lunghezza_parole[chiave]["n_max"])


func assegna_lettere(json_data) -> void:
	var index = 0
	for i_parola in json_data.words:
		var lunghezza = i_parola.length()
		lunghezza_parole[str(lunghezza) + "-size"].n_max += 1

func display() -> void:
	var keys_to_remove = []
	
	# Itera sulle chiavi del dizionario
	for size in lunghezza_parole.keys():
		# Verifica se n_max è 0
		if lunghezza_parole[size]["n_max"] == 0:
			# Aggiungi la chiave alla lista per rimuoverla dopo
			keys_to_remove.append(size)
		else:
			# Aggiorna il testo della Label "title"
			lunghezza_parole[size]["title"].text = size + ": " + str(lunghezza_parole[size]["n"]) + "/" + str(lunghezza_parole[size]["n_max"])
			
			# Aggiungi le label alla VBox
			vbox.add_child(lunghezza_parole[size]["title"])
			vbox.add_child(lunghezza_parole[size]["label"])
	
	# Rimuovi le chiavi con n_max == 0
	for key in keys_to_remove:
		lunghezza_parole.erase(key)
