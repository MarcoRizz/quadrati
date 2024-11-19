extends TextureRect

enum AttemptResult {
	NEW_FIND, #nuova parola trovata
	WRONG,    #parola sbagliata
	REPEATED, #parola già trovata in precedenza
	BONUS     #parola bonus
}

@onready var button_obj = $Button
@onready var lettera_obj = $Lettera
@onready var numero_obj = $Numero

signal attempt_start(tile: Object, letter: String)
signal selection_attempt(tile: Object, selected: bool, letter: String)

@export var grid_vect = Vector2()

var selected: bool = false
var look_forward = Vector2() #durante un attempt attivo, indica la tile successiva

var passingWords = [] #archivio le parole che possono passare per la tile
var startingWords = [] #archivio le parole che possono iniziare dalla tile

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_obj.mouse_filter = Control.MOUSE_FILTER_PASS


func set_letter(letters: Array) -> void:
	lettera_obj.text = letters[grid_vect.x][grid_vect.y]


func get_letter() -> String:
	return lettera_obj.text


func set_passingWords(indexes: Array, words: Array) -> void:
	for i in indexes[grid_vect.x][grid_vect.y]:
		passingWords.append(words[i])


func number_update(yesterday_mode: bool) -> void:
	var new_number = startingWords.size();
	numero_obj.text = str(new_number)
	if yesterday_mode:
		numero_obj.hide()
		modulate = Color.LIGHT_SLATE_GRAY
		return
	if not new_number:
		numero_obj.hide()
	if not passingWords.size():
		self_modulate = Color(1, 1, 1)
		modulate = Color(1, 1, 1, 0.4)
	else:
		modulate = Color(1, 1, 1, 1)


func selection_ok() -> void:
	selected = true
	self_modulate = Color(1, 1, 0.6)


func remove_selection() -> void:
	selected = false
	look_forward = Vector2()
	self_modulate = Color(1, 1, 1)


func set_result(attempt_result: AttemptResult, word: String, color: Color) -> void:
	if selected:
		self_modulate = color
	if attempt_result == AttemptResult.NEW_FIND:
		if passingWords.has(word):
			passingWords.erase(word)
		if startingWords.has(word):
			startingWords.erase(word)


func clear(yesterday_mode: bool) -> void:
	remove_selection()
	number_update(yesterday_mode)


func show_number(show_it: bool) -> void:
	if show_it and not startingWords.is_empty():
		numero_obj.show()
	else:
		numero_obj.hide()


func _on_button_button_down() -> void:
	attempt_start.emit(self, lettera_obj.text)


func _on_internal_area_mouse_entered() -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		selection_attempt.emit(self, selected, lettera_obj.text)
