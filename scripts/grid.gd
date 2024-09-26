extends Node2D

const grid_size := 4

signal attempt_result(word_finded: int, word: String, color: Color)
signal attempt_changed(word: String)
signal clear_grid
signal show_number(show: bool)

@export var tile_size := 90.0 #deprecated
@export var tile_spacing := 10.0 #deprecated

@onready var path: Line2D = $Path

@onready var tiles = [[$Node2D/tile00, $Node2D/tile01, $Node2D/tile02, $Node2D/tile03],
					  [$Node2D/tile10, $Node2D/tile11, $Node2D/tile12, $Node2D/tile13],
					  [$Node2D/tile20, $Node2D/tile21, $Node2D/tile22, $Node2D/tile23],
					  [$Node2D/tile30, $Node2D/tile31, $Node2D/tile32, $Node2D/tile33]]

var attempt = {"letter": [], "xy": []}
var ready_for_attempt = true
var number_shown = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for y in range(grid_size):
		for x in range(grid_size):
			#automatizzo i collegamenti
			connect("attempt_result", tiles[x][y]._on_grid_attempt_result)
			connect("clear_grid", tiles[x][y]._on_grid_clear_grid)
			connect("show_number", tiles[x][y]._on_grid_show_number)
			tiles[x][y].connect("selection_attempt", _on_tile_selection_attempt)
	show_number.emit(number_shown)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func assegna_lettere(json_data) -> void:
	var index = 0
	for i_tile in json_data.startingLinks:
		tiles[i_tile[0]][i_tile[1]].startingWords.append(json_data.words[index])
		index += 1
	for y in range(grid_size):
		for x in range(grid_size):
			#assegno le lettere
			tiles[x][y].get_node("Lettera").text = json_data.grid[x][y]
			for i_parola in json_data.passingLinks[x][y]:
				tiles[x][y].passingWords.append(json_data.words[i_parola])
			tiles[x][y].number_update()

func elaborate_tile_coordinate(grid_vector: Vector2) -> Vector2:
	return Vector2((tile_size + tile_spacing) * (grid_vector.x + 1.0/2), (tile_size + tile_spacing) * (grid_vector.y + 1.0/2))

func i_tile_from_attempt(i: int) -> Sprite2D:
	return tiles[attempt.xy[i].x][attempt.xy[i].y]

func _on_tile_selection_attempt(recived_vector, selected, letter):
	print("selection " + letter)
	print("position: " + str(recived_vector.x) + ", " + str(recived_vector.y))
	
	var attempt_len = len(attempt.xy)
	#capisco se sto tornando indietro o progredendo
	if not selected and (len(attempt.xy) == 0 or recived_vector.distance_to(attempt.xy[-1]) < 1.5):
		#aggiungo selezione
		path.mod_add_point(elaborate_tile_coordinate(recived_vector))
		attempt.letter.append(letter)
		attempt.xy.append(recived_vector)
		i_tile_from_attempt(-1).selection_ok()
		if attempt_len > 0:
			i_tile_from_attempt(-2).look_forward = attempt.xy[-1] - attempt.xy[-2]

	if selected and attempt_len > 1:
		if recived_vector - attempt.xy[-1] == - i_tile_from_attempt(-2).look_forward:
			#undo ultima selezione
			path.mod_remove_point(path.get_point_count() - 1)
			i_tile_from_attempt(-1).remove_selection()
			attempt.letter.resize(attempt_len - 1)
			attempt.xy.resize(attempt_len - 1)
	
	#attivo il segnale attempt_changed
	var nuova_parola: String
	for each_letter in attempt.letter:
		nuova_parola += each_letter
	attempt_changed.emit(nuova_parola)

func _on_main_attempt_result(result: int, word: String) -> void:
	var color
	match result:
		0:
			color = Color(1, 0.6, 0.6)
		1:
			color = Color(0.6, 1, 0.6)
		2:
			color = Color(0.6, 0.6, 0.6)
	
	$Path.modulate = color
	attempt_result.emit(result, word, color)
	print(attempt)
	ready_for_attempt = false
	$Timer.start()

func _on_timer_timeout() -> void:
	path.mod_clear_points()
	attempt.letter.clear()
	attempt.xy.clear()
	$Path.modulate = $Path.default_color
	clear_grid.emit()
	show_number.emit(number_shown)
		
	ready_for_attempt = true
