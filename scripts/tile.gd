extends Sprite2D

#const myenums = preload("res://scripts/enum.gd")

signal selection_attempt(grid_vector, selected, letter)

@export var grid_x: int = 0
@export var grid_y: int = 0

var selected: bool = false
var look_forward = Vector2(0, 0)

var words_array = [] #la uso per archiviare le parole che possono passare per la tile
var origin_modulate: Color = modulate

@onready var grid = $"../.."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func words_array_update() -> void:
	$Numero.text = str(len(words_array))

func selection_ok() -> void:
	selected = true
	modulate = Color(1, 1, 0.6)

func remove_selection() -> void:
	selected = false
	look_forward = Vector2(0, 0)
	modulate = origin_modulate
	words_array_update()

func _on_grid_attempt_result(word_finded: bool, word: String) -> void:
	#da inserire colore in funzione di result e contatore parole
	pass

func _on_grid_clear_grid() -> void:
	remove_selection()

func _on_grid_show_number(to_show: bool) -> void:
	if to_show:
		$Numero.show()
	else:
		$Numero.hide()

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click") and grid.ready_for_attempt:
		selection_attempt.emit(Vector2(grid_x, grid_y), selected, $Lettera.text)

func _on_area_2d_mouse_entered() -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		selection_attempt.emit(Vector2(grid_x, grid_y), selected, $Lettera.text)
