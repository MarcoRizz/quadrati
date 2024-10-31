extends Panel

enum AttemptResult {
	NEW_FIND, #nuova parola trovata
	WRONG, #parola sbagliata
	REPEATED #parola già trovata in precedenza
}

const parola_obj = preload("res://scenes/worldpanel_parola.tscn")

signal show_path(word: String)

@onready var vbox = $ScrollContainer/VBoxContainer
@onready var scroll_container = $ScrollContainer

var box_parole = {
	 "4": {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	 "5": {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	 "6": {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	 "7": {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	 "8": {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	 "9": {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	"10": {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	"11": {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	"12": {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	"13": {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	"14": {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	"15": {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	"16": {"n": 0, "n_max": 0, "title": Label.new(), "containers": []}
}
var all_words = Node.new() #qui salvo tutte le parole

# Variabili per l'espansione animata
var original_size_y = size.y
const extended_size_y = 350
const moving_vel = 500.0
var panel_y_bottom #la assegno in _ready()
var moving_up = false

func _ready() -> void:
	#impedisco il click delle lettere se Panel è esteso
	mouse_filter = Control.MOUSE_FILTER_STOP
	#rilevo la posizione globale
	panel_y_bottom = position.y + original_size_y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Esegui il calcolo solo se è necessario espandere o ridurre il pannello
	if (moving_up and size.y < extended_size_y) or (not moving_up and size.y > original_size_y):
		# Aggiorna size.y e applica il clamp per mantenerlo nei limiti
		size.y = clamp(size.y + moving_vel * delta * (1 if moving_up else -1), original_size_y, extended_size_y)
		
		# Aggiorna la posizione solo se size.y cambia
		position.y = panel_y_bottom - size.y

	# Controlla se è stato cliccato un label TODO da implementare in worldpanel_parola
	#if clicked_label == null:
		#return
	#else:
		#holding_click_delta_time += delta
		#
		#if click_global_position.distance_to(get_global_mouse_position()) > max_mouse_move:
			#clicked_label = null
			#return
		#else:
		#
			## Se il tempo di hold è stato superato, esegui un'azione
			#if holding_click_delta_time > max_holding_time:
				## Recupera il testo della label per comporre l'URL
				#var url = "https://www.google.com/search?q=" + clicked_label.text + "+vocabolario"
				#clicked_label = null
				#
				## Apre l'URL nel browser
				#OS.shell_open(url)


func instantiate(json: Dictionary) -> void:
	for i_parola in json.words:
		var lunghezza = i_parola.length()
		box_parole[str(lunghezza)].n_max += 1
		var new_parola = parola_obj.instantiate()
		new_parola.name = "_" + i_parola
		new_parola.text = i_parola
		all_words.add_child(new_parola)
	
	for size_n in box_parole:
		if box_parole[size_n]["n_max"] == 0:
			vbox.remove_child(vbox.get_node(str(size_n) + "_titolo"))
			vbox.remove_child(vbox.get_node(str(size_n) + "_box"))
		else:
			# Inizializzo il titolo
			vbox.get_node(str(size_n) + "_titolo").text = size_n + "-lettere: 0/" + str(box_parole[size_n]["n_max"])


func add_word(word: String, increase_count: bool = true):
	var lunghezza_char = str(word.length())
	
	all_words.get_node("_" + word).reparent(vbox.get_node(lunghezza_char + "_box"))
	
	if increase_count:
		# Aggiorna il conteggio delle parole trovate
		var n = box_parole[lunghezza_char]["n"] + 1
		var n_max = box_parole[lunghezza_char]["n_max"]
		var title = vbox.get_node(str(lunghezza_char) + "_titolo")
		box_parole[lunghezza_char]["n"] = n
		title.text = lunghezza_char + "-lettere: " + str(n) + "/" + str(box_parole[lunghezza_char]["n_max"])
		if n >= n_max:
			title.set("theme_override_colors/font_color", Color.AQUAMARINE)
	else:
		pass
		#word_label.self_modulate = Color(1, 0.3, 0.3)  #TODO per la visualizzazione delle parole in history_mode


#func creat_clickable_label(word: String) -> Label:
	## Crea un nuovo Label per la parola
	#var word_label = Label.new()
	#word_label.text = word
	#word_label.mouse_filter = Control.MOUSE_FILTER_PASS
	#
	## Connetti l'evento di input alla label
	#word_label.connect("gui_input", _on_label_clicked.bind(word_label))
	#word_label.connect("mouse_exited", _on_label_exited)
	#
	#return word_label


func _on_button_pressed() -> void:
	$Button.rotation = (0.0 if moving_up else PI)
	moving_up = not moving_up


	# Gestisci i clic fuori dal Panel
func _input(event):
	if size.y == extended_size_y and event is InputEventMouseButton and event.pressed:
			# Controlla se il clic è avvenuto fuori dal Panel
			var mouse_pos = get_global_mouse_position()
			var panel_rect = Rect2(global_position, size)
			# Usa la trasformazione globale per verificare la posizione del mouse rispetto al Button
			var button_global_position = $Button.get_global_position()
			var button_rect = Rect2(button_global_position - (Vector2() if $Button.rotation == 0 else $Button.size), $Button.size)
			
			if not panel_rect.has_point(mouse_pos) and not button_rect.has_point(mouse_pos):
				$Button.rotation = 0
				moving_up = false


## Funzione che si attiva al clic della label
#func _on_label_clicked(event: InputEvent, label: Label) -> void:
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#if event.is_pressed():
			#clicked_label = label
			#click_global_position = get_global_mouse_position()
			#holding_click_delta_time = 0
		#
		#elif event.is_released() and label == clicked_label:
			#show_path.emit(clicked_label.text)
			#clicked_label = null
#
#
#func _on_label_exited() -> void:
	#clicked_label = null
#
#
#func _on_main_reveal_word(word: String) -> void:
	#add_word(word, false)
