extends Panel

signal show_path(word: String)

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

# Variabili per l'espansione animata
var original_size_y = size.y
const extended_size_y = 350
const moving_vel = 500.0
var panel_y_bottom #la assegno in _ready()
var moving_up = false

# Variabili per la costruzione delle Label
var font #salvo il font per calcolare le lunghezze delle stringhe
var h_label
var w_container
const dash_string = "-"
var w_dash_label

# Variabili per il click delle parole
const max_holding_time = 1.0 #secondi
var clicked_label
var click_global_position
var max_mouse_move = 10.0 #se sto trascinando il Panel evito che continui a cliccare la parola
var holding_click_delta_time

func _ready() -> void:
	#imposto le variabili statiche
	# Ottieni il font del Label (assicurati che sia definito un font, altrimenti usa il font di default)
	font = Label.new().get_theme_font("font")  # Recupera il font dal tema
	if font == null:
		font = Label.new().get_font("CustomFont")  # Prova a ottenere il font personalizzato se esiste
	h_label = font.get_string_size(dash_string).y
	w_container = scroll_container.size.x
	w_dash_label = font.get_string_size(dash_string).x
	
	#impedisco il click delle lettere se Panel è esteso
	mouse_filter = Control.MOUSE_FILTER_STOP
	#rilevo la posizione globale
	panel_y_bottom = get_global_position().y + original_size_y
	
	# Impostazioni dei Nodi di lunghezza_parole
	for size_n in lunghezza_parole:
		lunghezza_parole[size_n]["title"].set("theme_override_colors/font_color", Color.BLANCHED_ALMOND)
		# Aggiungi il primo HBoxContainer vuoto
		var hbox = HBoxContainer.new()
		hbox.custom_minimum_size.x = w_container
		hbox.custom_minimum_size.y = h_label
		lunghezza_parole[size_n]["containers"].append(hbox)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Esegui il calcolo solo se è necessario espandere o ridurre il pannello
	if (moving_up and size.y < extended_size_y) or (not moving_up and size.y > original_size_y):
		# Aggiorna size.y e applica il clamp per mantenerlo nei limiti
		size.y = clamp(size.y + moving_vel * delta * (1 if moving_up else -1), original_size_y, extended_size_y)
		
		# Aggiorna la posizione solo se size.y cambia
		position.y = panel_y_bottom - size.y

	# Controlla se è stato cliccato un label
	if clicked_label == null:
		return
	else:
		holding_click_delta_time += delta
		
		if click_global_position.distance_to(get_global_mouse_position()) > max_mouse_move:
			clicked_label = null
			return
		else:
		
			# Se il tempo di hold è stato superato, esegui un'azione
			if holding_click_delta_time > max_holding_time:
				# Recupera il testo della label per comporre l'URL
				var url = "https://www.google.com/search?q=" + clicked_label.text + "+vocabolario"
				clicked_label = null
				
				# Apre l'URL nel browser
				OS.shell_open(url)


func _on_main_attempt_result(word_finded: int, word: String) -> void:
	if word_finded == 1:
		add_word(word)

func add_word(word: String, increase_count: bool = true):
	var lunghezza = word.length()
	# Verifica la size_n corrispondente alla lunghezza della parola
	for size_n in lunghezza_parole:
		if str(lunghezza) + "-lettere" == size_n:
			var n = lunghezza_parole[size_n]["n"]
			var n_max = lunghezza_parole[size_n]["n_max"]
			var current_containers = lunghezza_parole[size_n]["containers"]
			var last_container = current_containers[-1]  # Ottieni l'ultimo HBoxContainer
			
			# Crea un nuovo Label per la parola
			var word_label = creat_clickable_label(word)
			
			if n > 0:
				# Se la nuova parola non ci sta nell'ultimo container, crea un nuovo HBoxContainer (vai a capo)
				var x_pos = 0
				for each_label in last_container.get_children():
					x_pos += font.get_string_size(each_label.text).x + 4
					
				if x_pos + w_dash_label + font.get_string_size(word).x + 8 > last_container.get_combined_minimum_size().x: #last_label.position.x + last_label.size.x + w_dash_label + font.get_string_size(word).x + 8 > last_container.get_combined_minimum_size().x:
					var hbox = HBoxContainer.new()
					hbox.custom_minimum_size.x = w_container
					hbox.custom_minimum_size.y = h_label
					current_containers.append(hbox)
					last_container.add_sibling(hbox)
					last_container = hbox
				else:
					# Aggiungi il trattino "-" se non è la prima parola nel container
					var dash_label = Label.new()
					dash_label.text = dash_string
					last_container.add_child(dash_label)
			
			# Aggiungi la parola all'ultimo HBoxContainer
			last_container.add_child(word_label)
			
			if increase_count:
				# Aggiorna il conteggio delle parole trovate
				n +=1
				lunghezza_parole[size_n]["n"] = n
				lunghezza_parole[size_n]["title"].text = size_n + ": " + str(n) + "/" + str(n_max)
				if n >= n_max:
					lunghezza_parole[size_n]["title"].set("theme_override_colors/font_color", Color.AQUAMARINE)
			else:
				word_label.self_modulate = Color(1, 0.3, 0.3)


func creat_clickable_label(word: String) -> Label:
	# Crea un nuovo Label per la parola
	var word_label = Label.new()
	word_label.text = word
	word_label.mouse_filter = Control.MOUSE_FILTER_PASS
	
	# Connetti l'evento di input alla label
	word_label.connect("gui_input", _on_label_clicked.bind(word_label))
	word_label.connect("mouse_exited", _on_label_exited)
	
	return word_label


func instantiate(json: Dictionary) -> void:
	for i_parola in json.words:
		var lunghezza = i_parola.length()
		lunghezza_parole[str(lunghezza) + "-lettere"].n_max += 1
	
	for size_n in lunghezza_parole:
		if lunghezza_parole[size_n]["n_max"] == 0:
			#lunghezza_parole.erase(size_n)
			pass
		else:
			lunghezza_parole[size_n]["title"].text = size_n + ": 0/" + str(lunghezza_parole[size_n]["n_max"])
			vbox.add_child(lunghezza_parole[size_n]["title"])
			
			# Aggiungi tutti gli HBoxContainer per la specifica lunghezza di parole
			for container in lunghezza_parole[size_n]["containers"]:
				vbox.add_child(container)


func deinstantiate() -> void:
	#creo un "buffer" di nodi da eliminare (per evitare che nei get_children successivi vengano rilevati oggetti in coda di eiminazione)
	#var delete_buffer = Node2D.new()
	#add_child(delete_buffer)
	
	# Scollego e resetto tutte le righe in WordPanel
	for child in vbox.get_children():
		vbox.remove_child(child)
		if child.is_class("HBoxContainer"):
			child.queue_free()
	for size_n in lunghezza_parole:
		lunghezza_parole[size_n]["n_max"] = 0
		lunghezza_parole[size_n]["n"] = 0
		lunghezza_parole[size_n]["title"].set("theme_override_colors/font_color", Color.BLANCHED_ALMOND)
		# non riassegno i titoli tanto reinizializzo subito
		
		# Elimino tutte le righe contenenti parole (hbox) eccetto la prima
		#for i_hbox in range(1, len(lunghezza_parole[size_n]["containers"])):
		#	var child = lunghezza_parole[size_n]["containers"][i_hbox]
		#	child.reparent(delete_buffer)
			#child.queue_free()
		
		lunghezza_parole[size_n]["containers"].clear()
		
		# Aggiungi il primo HBoxContainer vuoto
		var hbox = HBoxContainer.new()
		hbox.custom_minimum_size.x = w_container
		hbox.custom_minimum_size.y = h_label
		lunghezza_parole[size_n]["containers"].append(hbox)
		# La prima e unica riga la svuoto
		for i_label in lunghezza_parole[size_n]["containers"][0].get_children():
			#i_label.reparent(delete_buffer)
			lunghezza_parole[size_n]["containers"][0].remove_child(i_label)
			i_label.queue_free()
	#delete_buffer.queue_free()


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


# Funzione che si attiva al clic della label
func _on_label_clicked(event: InputEvent, label: Label) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			clicked_label = label
			click_global_position = get_global_mouse_position()
			holding_click_delta_time = 0
		
		elif event.is_released() and label == clicked_label:
			show_path.emit(clicked_label.text)
			clicked_label = null


func _on_label_exited() -> void:
	clicked_label = null


func _on_main_reveal_word(word: String) -> void:
	add_word(word, false)
