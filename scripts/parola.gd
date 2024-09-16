extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_grid_attempt_changed(word: String) -> void:
	self.text = word

func _on_grid_clear_grid() -> void:
	self.text = ""
