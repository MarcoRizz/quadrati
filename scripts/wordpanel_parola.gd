extends Button

signal show_path(word: String)

# Variabili per il click delle parole
const max_holding_time = 0.5 #secondi
var holding_click_delta_time


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_pressed():
		# Se il tempo di hold è stato superato, esegui un'azione
		if holding_click_delta_time > max_holding_time:
			# Recupera il testo della label per comporre l'URL
			var url = "https://www.google.com/search?q=" + text + "+vocabolario"
			
			# Apre l'URL nel browser
			OS.shell_open(url)


func _on_button_down() -> void:
	holding_click_delta_time = 0


func set_revealed_word() -> void:
	var color = Color(1, 0.3, 0.3)
	set("theme_override_colors/font_color", color)
	set("theme_override_colors/font_pressed_color", color)
	set("theme_override_colors/font_hover_color", color)


func _on_pressed() -> void:
	show_path.emit(text)
