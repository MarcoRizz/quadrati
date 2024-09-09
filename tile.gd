extends Sprite2D

const myenums = preload("res://enum.gd")

signal selection(grid_x, grid_y, letter)

@export var grid_x:int = 0
@export var grid_y:int = 0
@export var state: Constants.state = Constants.state.UNSELECTABLE

var words_array #la userò per segnare quante parole possono passare per la singola lettera
var origin_modulate: Color = self.modulate

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if get_rect().has_point(get_local_mouse_position()) and state == Constants.state.SELECTABLE:
			self.modulate = Color(1, 1, 0.6)
			state = Constants.state.SELECTED
			selection.emit(grid_x, grid_y, get_node("Label").text)

func _input(event):
	if event is InputEventMouseButton:
		if event.is_action_pressed("clic"):
			if get_rect().has_point(get_local_mouse_position()):
				state = Constants.state.SELECTABLE
				
		if event.is_action_released("clic"):
			self.modulate = origin_modulate
			state = Constants.state.UNSELECTABLE

func undo() -> void:
	self.modulate = origin_modulate
