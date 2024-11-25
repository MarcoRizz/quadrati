extends TextureButton

@export var hints_left: int = 3

@onready var label_obj = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label_obj.text = str(hints_left)


func _on_pressed() -> void:
	set_hints_left(hints_left - 1)


func set_hints_left(value: int) -> void:
	hints_left = value
	label_obj.text = str(hints_left)
	
	if hints_left <= 0:
		disabled = true
		modulate.a = 0.4
