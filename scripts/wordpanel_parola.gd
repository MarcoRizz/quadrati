extends Button

signal show_path(word: String)

# Variabili per il click delle parole
const max_holding_time = 0.5 #secondi
var valid_click: bool
var click_global_position: Vector2
var max_mouse_move = 10.0 #se sto trascinando il Panel evito che continui a cliccare la parola
var holding_click_delta_time


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_pressed() and valid_click:
		holding_click_delta_time += delta
		
		if click_global_position.distance_to(get_global_mouse_position()) > max_mouse_move:
			valid_click = false
			return
		else:
			# Se il tempo di hold è stato superato, esegui un'azione
			if holding_click_delta_time > max_holding_time:
				# Recupera il testo della label per comporre l'URL
				var url = "https://www.google.com/search?q=" + text + "+vocabolario"
				valid_click = false
				
				# Apre l'URL nel browser
				OS.shell_open(url)


func _on_button_down() -> void:
	click_global_position = get_global_mouse_position()
	holding_click_delta_time = 0
	valid_click = true


func _on_button_up() -> void:
	if valid_click:
		show_path.emit(text)
		valid_click = false


func set_revealed_word() -> void:
	var color = Color(1, 0.3, 0.3)
	set("theme_override_colors/font_color", color)
	set("theme_override_colors/font_pressed_color", color)
	set("theme_override_colors/font_hover_color", color)
