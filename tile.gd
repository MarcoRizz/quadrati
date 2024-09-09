extends Sprite2D

signal selection(grid_x, grid_y, letter)

@export var grid_x = 1
@export var grid_y = 1

var words_array #la userò per segnare quante parole possono passare per la singola lettera
var state_selected: bool = false
var origin_modulate: Color = self.modulate

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if get_parent().valid_clic and get_rect().has_point(get_local_mouse_position()):
			if not state_selected:
				selection.emit(grid_x, grid_y, get_node("Label").text)
				self.modulate = Color(1, 1, 0.6)
				state_selected = true
			


func _input(event):
	if event is InputEventMouseButton:
		if event.is_action_pressed("clic"):
			if get_rect().has_point(get_local_mouse_position()):
				get_parent().valid_clic = true

		if event.is_action_released("clic") and state_selected:
			self.modulate = origin_modulate
			state_selected = false
