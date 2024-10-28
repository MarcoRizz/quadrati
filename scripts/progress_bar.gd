extends ProgressBar

signal initials_threshold_signal

var initials_threshold = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func increase(word: String) -> void:
	value += len(word)
	
	if not initials_threshold and value * 3.0 > max_value * 1.0:
		initials_threshold = true
		initials_threshold_signal.emit()

func reset():
	max_value = 0
	value = 0
	initials_threshold = false
