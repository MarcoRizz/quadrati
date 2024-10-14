extends ProgressBar

signal initials_threshold_signal

var initials_threshold = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_main_attempt_result(result: int, word: String) -> void:
	if result == 1:
		value += len(word)
	
	if not initials_threshold and value * 3.0 > max_value * 1.0:
		initials_threshold = true
		initials_threshold_signal.emit()
