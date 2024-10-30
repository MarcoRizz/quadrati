extends Node2D

#const myenums = preload("res://scripts/enum.gd")
enum AttemptResult {
	NEW_FIND, #nuova parola trovata
	WRONG, #parola sbagliata
	REPEATED #parola già trovata in precedenza
}

signal attempt_start(tile: Node2D, letter: String)
signal selection_attempt(tile: Node2D, selected: bool, letter: String)

@export var grid_vect = Vector2()

var selected: bool = false
var look_forward = Vector2() #durante un attempt attivo, indica la tile successiva

var passingWords = [] #archivio le parole che possono passare per la tile
var startingWords = [] #archivio le parole che possono iniziare dalla tile

@onready var grid = $".."   #TODO: <-- da timuovere rif a grid

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D/Button.mouse_filter = Control.MOUSE_FILTER_PASS


func set_letter(letters: Array) -> void:
	$Sprite2D/Lettera.text = letters[grid_vect.x][grid_vect.y]


func set_passingWords(indexes: Array, words: Array) -> void:
	for i in indexes[grid_vect.x][grid_vect.y]:
		passingWords.append(words[i])


func number_update() -> void:
	var new_number = len(startingWords);
	$Sprite2D/Numero.text = str(new_number)
	if grid.history_mode:    #TODO: <-- da timuovere rif a grid
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
	look_forward = Vector2()
	$Sprite2D.self_modulate = Color(1, 1, 1)


func set_result(attempt_result: AttemptResult, word: String, color: Color) -> void:
	if selected:
		$Sprite2D.self_modulate = color
	if attempt_result == AttemptResult.NEW_FIND:
		if passingWords.has(word):
			passingWords.erase(word)
		if startingWords.has(word):
			startingWords.erase(word)


func clear() -> void:
	remove_selection()
	number_update()


func show_number(show_it: bool) -> void:
	if show_it and len(startingWords) != 0:
		$Sprite2D/Numero.show()
	else:
		$Sprite2D/Numero.hide()


func _on_area_2d_mouse_entered() -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		selection_attempt.emit(self, selected, $Sprite2D/Lettera.text)


func _on_button_button_down() -> void:
	attempt_start.emit(self, $Sprite2D/Lettera.text)
