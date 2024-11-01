extends Panel

enum AttemptResult {
	NEW_FIND, #nuova parola trovata
	WRONG, #parola sbagliata
	REPEATED #parola già trovata in precedenza
}

const parola_obj = preload("res://scenes/wordpanel_parola.tscn")

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


func instantiate(json: Dictionary) -> void:
	for i_parola in json.words:
		var lunghezza = i_parola.length()
		box_parole[str(lunghezza)].n_max += 1
		var new_parola = parola_obj.instantiate()
		new_parola.name = "_" + i_parola
		new_parola.text = i_parola
		new_parola.show_path.connect(_on_parola_show_path)
		all_words.add_child(new_parola)
	
	for size_n in box_parole:
		if box_parole[size_n]["n_max"] == 0:
			vbox.remove_child(vbox.get_node(str(size_n) + "_titolo"))
			vbox.remove_child(vbox.get_node(str(size_n) + "_box"))
		else:
			# Inizializzo il titolo
			vbox.get_node(str(size_n) + "_titolo").text = size_n + "-lettere: 0/" + str(box_parole[size_n]["n_max"])


func add_word(word: String):
	var lunghezza_char = str(word.length())
	
	all_words.get_node("_" + word).reparent(vbox.get_node(lunghezza_char + "_box"))
	
	# Aggiorna il conteggio delle parole trovate
	var n = box_parole[lunghezza_char]["n"] + 1
	var n_max = box_parole[lunghezza_char]["n_max"]
	var title = vbox.get_node(str(lunghezza_char) + "_titolo")
	box_parole[lunghezza_char]["n"] = n
	title.text = lunghezza_char + "-lettere: " + str(n) + "/" + str(box_parole[lunghezza_char]["n_max"])
	if n >= n_max:
		title.set("theme_override_colors/font_color", Color.AQUAMARINE)


func reveal_remaining_words() -> void:
	for word_obj in all_words.get_children():
		word_obj.reparent(vbox.get_node(str(word_obj.name.length() - 1) + "_box"))
		word_obj.set_revealed_word()


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


func _on_parola_show_path(word: String) -> void:
	show_path.emit(word)
