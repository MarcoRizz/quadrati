extends ProgressBar

signal over_1_4_signal

var over_1_4 = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_main_attempt_result(result: int, word: String) -> void:
	if result == 1:
		value += len(word)
	
	if not over_1_4 and value * 4.0 > max_value * 1.0:
		over_1_4 = true
		over_1_4_signal.emit()
