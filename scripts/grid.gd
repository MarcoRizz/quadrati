extends Node2D

#const node_tile = preload("res://scenes/tile.tscn")
const myenums = preload("res://scripts/enum.gd")
const grid_size := 4

signal attempt_result(word_finded: bool, word: String)
signal attempt_changed(word: String)
signal clear_grid

@export var tile_size := 90.0 #deprecated
@export var tile_spacing := 10.0 #deprecated

@onready var path: Line2D = $Path

@onready var tiles = [[$Node2D/tile00, $Node2D/tile01, $Node2D/tile02, $Node2D/tile03],
			 [$Node2D/tile10, $Node2D/tile11, $Node2D/tile12, $Node2D/tile13],
			 [$Node2D/tile20, $Node2D/tile21, $Node2D/tile22, $Node2D/tile23],
			 [$Node2D/tile30, $Node2D/tile31, $Node2D/tile32, $Node2D/tile33]]

var attempt = {"letter": [], "xy": []}
var ready_for_attempt = true
#node_tile.scale.x = tile_size / node_tile.texture.get_width()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_grid()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func generate_grid():
	#leggo il file json di oggi
	var file = "res://daily_map.json"
	var json_as_text = FileAccess.get_file_as_string(file)
	var json_as_dict = JSON.parse_string(json_as_text)

	#serve un controllo sulla corretta costruzione del file json_as_dict

	#posiziono le tile
	for y in range(grid_size):
		for x in range(grid_size):
			#assegno le lettere
			tiles[x][y].get_node("Label").text = json_as_dict.today.grid[y][x]

func _on_tile_selection(recived_vector, selected, letter):
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

func elaborate_tile_coordinate(grid_vector: Vector2) -> Vector2:
	return Vector2((tile_size + tile_spacing) * (grid_vector.x + 1.0/2), (tile_size + tile_spacing) * (grid_vector.y + 1.0/2))

func i_tile_from_attempt(i: int) -> Sprite2D:
	return tiles[attempt.xy[i].x][attempt.xy[i].y]


func _on_main_attempt_result(word_finded: bool, word: String) -> void:
	attempt_result.emit(word_finded, word)
	print(attempt)
	ready_for_attempt = false
	$Timer.start()


func _on_timer_timeout() -> void:
	path.mod_clear_points()
	attempt.letter.clear()
	attempt.xy.clear()
	clear_grid.emit()
	ready_for_attempt = true
