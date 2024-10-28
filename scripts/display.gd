extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_grid_attempt_changed(word: String) -> void:
	self.text = word


func _on_grid_clear() -> void:
	self.text = ""
