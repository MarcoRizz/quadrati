extends Node2D

#const myenums = preload("res://scripts/enum.gd")

signal selection_attempt(grid_vector, selected, letter)

@export var grid_x: int = 0
@export var grid_y: int = 0

var selected: bool = false
var look_forward = Vector2(0, 0) #durante un tentativo indica la tile successiva

var passingWords = [] #archivio le parole che possono passare per la tile
var startingWords = [] #archivio le parole che possono iniziare dalla tile

@onready var grid = $".."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D/Button.mouse_filter = Control.MOUSE_FILTER_PASS


func number_update() -> void:
	var new_number = len(startingWords);
	$Sprite2D/Numero.text = str(new_number)
	if grid.history_mode:
		$Sprite2D/Numero.hide()
		$Sprite2D.modulate = Color.LIGHT_SLATE_GRAY
		return
	if not new_number:
		$Sprite2D/Numero.hide()
	if not len(passingWords):
		$Sprite2D.self_modulate = Color(1, 1, 1)
		$Sprite2D.modulate = Color(1, 1, 1, 0.4)
	else:
		$Sprite2D.modulate = Color(1, 1, 1, 1)


func selection_ok() -> void:
	selected = true
	$Sprite2D.self_modulate = Color(1, 1, 0.6)


func remove_selection() -> void:
	selected = false
	look_forward = Vector2(0, 0)
	$Sprite2D.self_modulate = Color(1, 1, 1)


func _on_grid_attempt_result(attempt_result: int, word: String, color: Color) -> void:
	if selected:
		$Sprite2D.self_modulate = color
	if attempt_result == 1:
		if passingWords.has(word):
			passingWords.erase(word)
		if startingWords.has(word):
			startingWords.erase(word)


func _on_grid_clear_grid() -> void:
	remove_selection()
	number_update()


func _on_grid_show_number(to_show: bool) -> void:
	if to_show and len(startingWords) != 0:
		$Sprite2D/Numero.show()
	else:
		$Sprite2D/Numero.hide()


func _on_area_2d_mouse_entered() -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and grid.valid_attempt:
		print("passed on {", grid_x, ", ", grid_y, "}")
		selection_attempt.emit(Vector2(grid_x, grid_y), selected, $Sprite2D/Lettera.text)


func _on_button_button_down() -> void:
	if grid.ready_for_attempt:
		selection_attempt.emit(Vector2(grid_x, grid_y), selected, $Sprite2D/Lettera.text)
