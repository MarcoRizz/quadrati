extends Sprite2D

#const myenums = preload("res://scripts/enum.gd")

signal selection_attempt(grid_vector, selected, letter)

@export var grid_x: int = 0
@export var grid_y: int = 0
#@export var state: Constants.state = Constants.state.UNSELECTABLE
@export var circle_r := 80
@export var sel_area_reduc_xside := -30 #quanti pixel bisogna entrare nella tile per selezionarla

var selected: bool = false
var look_forward = Vector2(0, 0)

var words_array #la userò per segnare quante parole possono passare per la singola lettera
var origin_modulate: Color = self.modulate

#@onready var grid = $"../.."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if event is InputEventMouseButton:
		if event.is_action_pressed("click") and $"../..".ready_for_attempt:
			if get_rect().grow(sel_area_reduc_xside).has_point(get_local_mouse_position()): #todo: sostituire con Area2D click
				selection_attempt.emit(Vector2(grid_x, grid_y), selected, get_node("Label").text)

func remove_selection() -> void:
	selected = false
	look_forward = Vector2(0, 0)
	self.modulate = origin_modulate

func _on_grid_attempt_result(word_finded: bool, word: String) -> void:
	#da inserire colore in funzione di result e contatore parole
	pass


func _on_area_2d_mouse_entered() -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		#self.modulate = Color(1, 1, 0.6)
		#state = Constants.state.SELECTED
		selection_attempt.emit(Vector2(grid_x, grid_y), selected, get_node("Label").text)
			
func selection_ok() -> void:
	selected = true
	self.modulate = Color(1, 1, 0.6)


func _on_timer_timeout() -> void:
	self.modulate = origin_modulate
	print("timer timout")


func _on_grid_clear_grid() -> void:
	remove_selection()
