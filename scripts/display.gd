extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_grid_attempt_changed(add_char: bool, letter: String) -> void:
	if add_char:
		text += letter
	else:
		text = text.erase(text.length() - 1, 1)


func _on_grid_clear() -> void:
	text = ""
