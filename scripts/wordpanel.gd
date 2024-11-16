extends Panel

const parola_obj = preload("res://scenes/wordpanel_parola.tscn")

signal show_path(word: String)
signal expand(expansion_toggle: bool)

@onready var vbox_obj = $ScrollContainer/VBoxContainer
@onready var button_obj = $ExpandButton

var yesterday_mode = false

var box_parole = {
	 "4":    {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	 "5":    {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	 "6":    {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	 "7":    {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	 "8":    {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	 "9":    {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	"10":    {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	"11":    {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	"12":    {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	"13":    {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	"14":    {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	"15":    {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	"16":    {"n": 0, "n_max": 0, "title": Label.new(), "containers": []},
	"bonus": {"n": 0, "n_max": 0, "title": Label.new(), "containers": []}
}
var all_words = Node.new() #qui salvo tutte le parole

var expanded = false

func _ready() -> void:
	#impedisco il click delle lettere se Panel è esteso
	mouse_filter = Control.MOUSE_FILTER_STOP


func instantiate(json: Dictionary) -> void:
	for i_parola in json.words:
		var lunghezza = i_parola.length()
		box_parole[str(lunghezza)].n_max += 1
		var new_parola = parola_obj.instantiate()
		new_parola.name = "_" + i_parola
		new_parola.text = i_parola
		new_parola.show_path.connect(_on_parola_show_path)
		all_words.add_child(new_parola)
	
	if json.has("bonus"):
		for i_parola in json.bonus:
			box_parole["bonus"].n_max += 1
			var new_parola = parola_obj.instantiate()
			new_parola.name = "_" + i_parola
			new_parola.text = i_parola
			new_parola.show_path.connect(_on_parola_show_path)
			all_words.add_child(new_parola)
	
	for size_n in box_parole:
		if box_parole[size_n]["n_max"] == 0:
			vbox_obj.remove_child(vbox_obj.get_node(size_n + "_titolo"))
			vbox_obj.remove_child(vbox_obj.get_node(size_n + "_box"))
		else:
			# Inizializzo il titolo
			if not size_n == "bonus":
				vbox_obj.get_node(size_n + "_titolo").text = size_n + "-lettere: 0/" + str(box_parole[size_n]["n_max"])
			else:
				vbox_obj.get_node(size_n + "_titolo").text = "Bonus: 0/" + str(box_parole[size_n]["n_max"])


func add_word(word: String):
	var lunghezza_char = str(word.length())
	
	all_words.get_node("_" + word).reparent(vbox_obj.get_node(lunghezza_char + "_box"))
	
	# Aggiorna il conteggio delle parole trovate
	var n = box_parole[lunghezza_char]["n"] + 1
	var n_max = box_parole[lunghezza_char]["n_max"]
	var title = vbox_obj.get_node(str(lunghezza_char) + "_titolo")
	box_parole[lunghezza_char]["n"] = n
	title.text = lunghezza_char + "-lettere: " + str(n) + "/" + str(box_parole[lunghezza_char]["n_max"])
	if n >= n_max:
		title.set("theme_override_colors/font_color", Color.AQUAMARINE)

func add_bonus(word: String):	
	all_words.get_node("_" + word).reparent(vbox_obj.get_node("bonus_box"))
	
	# Aggiorna il conteggio delle parole trovate
	var n = box_parole["bonus"]["n"] + 1
	var n_max = box_parole["bonus"]["n_max"]
	var title = vbox_obj.get_node("bonus_titolo")
	box_parole["bonus"]["n"] = n
	title.text = "Bonus: " + str(n) + "/" + str(box_parole["bonus"]["n_max"])
	if n >= n_max:
		title.set("theme_override_colors/font_color", Color.AQUAMARINE)


func reveal_remaining_words() -> void:
	for word_obj in all_words.get_children():
		word_obj.reparent(vbox_obj.get_node(str(word_obj.name.length() - 1) + "_box"))
		word_obj.set_revealed_word()


func _on_button_pressed() -> void:
	button_obj.rotation = (PI if expanded else 0.0)
	expanded = not expanded
	expand.emit(expanded)
	print("expand emitted: ", expanded)


func _on_parola_show_path(word: String) -> void:
	show_path.emit(word)


func set_yesterday_mode() -> void:
	yesterday_mode = true
	button_obj.hide()
