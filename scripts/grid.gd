extends Control

enum AttemptResult {
	NEW_FIND, #nuova parola trovata
	WRONG,    #parola sbagliata
	REPEATED, #parola già trovata in precedenza
	BONUS     #parola bonus
}

const grid_size := 4

signal attempt_changed(add_char: bool, char: String)
signal attempt_emitted(word: String)
signal clear()

@export var tile_size := 90.0 #todo: prenderle dalla GUI
@export var tile_spacing := 10.0 #todo: prenderle dalla GUI

@onready var path: Line2D = $GridContainer/Path

@onready var tiles = [[$GridContainer/tile00, $GridContainer/tile01, $GridContainer/tile02, $GridContainer/tile03],
					  [$GridContainer/tile10, $GridContainer/tile11, $GridContainer/tile12, $GridContainer/tile13],
					  [$GridContainer/tile20, $GridContainer/tile21, $GridContainer/tile22, $GridContainer/tile23],
					  [$GridContainer/tile30, $GridContainer/tile31, $GridContainer/tile32, $GridContainer/tile33]]

var attempt_tiles: Array[Object]
var ready_for_attempt = false
var valid_attempt = false
var number_shown = false

var rot_on = 0 #comando di rotazione: -1 antiorario, 0 fermo, +1 orario
var rot_last = 0 #ultimo angolo statico [0, 270]
var rot_speed = 2.0

var yesterday_mode = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().call_group("tiles_group", "show_number", number_shown)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if rot_on != 0:
		$GridContainer.rotation += delta * rot_speed * rot_on
		
		var rot_target = rot_last + (PI / 2 * rot_on)
		
		# Verifica se l'angolo ha superato il limite
		if (rot_on == 1 and $GridContainer.rotation > rot_target) or (rot_on == -1 and $GridContainer.rotation < rot_target):
			# Correggi l'angolo
			$GridContainer.rotation = rot_target
			rot_last = rot_target
			rot_on = 0  # Ferma la rotazione
			ready_for_attempt = true;

		for tile in get_tree().get_nodes_in_group("tiles_group"):
				tile.rotation = -$GridContainer.rotation


func _input(event):
	if event.is_action_released("click"):
		if not valid_attempt and $Timer.is_stopped():
			#potrei avere un path plottato
			path.mod_clear_points()
			path.default_color = Color.YELLOW
		
		elif valid_attempt:
			attempt_emitted.emit()


func instantiate(data: Dictionary) -> void:
	# Assegno le lettere
	get_tree().call_group("tiles_group", "set_letter", data.grid)
	
	# Assegno le tessere iniziali
	var index = 0
	for tile in data.startingLinks:
		tiles[tile[0]][tile[1]].startingWords.append(data.words[index])
		index += 1
	
	# Assegno le parole di passaggio
	get_tree().call_group("tiles_group", "set_passingWords", data.passingLinks, data.words)
	
	# Aggiorno la griglia
	get_tree().call_group("tiles_group", "number_update", yesterday_mode)
	$Timer.start()


func _on_tile_attempt_start(recived_tile: Object, letter: String) -> void:
	if ready_for_attempt:
		path.mod_clear_points()
		path.default_color = Color.YELLOW
		valid_attempt = true
		
		#aggiungo selezione
		path.mod_add_point(recived_tile.position + recived_tile.size / 2 + $GridContainer.position)
		attempt_tiles.append(recived_tile)
		recived_tile.selection_ok()
		
		#attivo il segnale attempt_changed
		attempt_changed.emit(true, letter)

func _on_tile_selection_attempt(recived_tile: Object, selected: bool, letter: String):
	if valid_attempt:
		var attempt_len = attempt_tiles.size()
		#capisco se sto tornando indietro o progredendo
		if selected:
			if attempt_len > 1 and recived_tile.grid_vect + attempt_tiles[-2].look_forward == attempt_tiles[-1].grid_vect:
				# Se la tile selezionata sta guardando in direzione dell'ultima tile in attempt significa che sto tornando indietro --> undo ultima selezione
				path.mod_remove_point(path.get_point_count() - 1)
				attempt_tiles[-1].remove_selection()
				attempt_tiles.resize(attempt_len - 1)
				
				attempt_changed.emit(not selected, letter)
		else:
			if recived_tile.grid_vect.distance_to(attempt_tiles[-1].grid_vect) < 1.5:
				#aggiungo selezione
				path.mod_add_point(recived_tile.position + recived_tile.size / 2 + $GridContainer.position)
				attempt_tiles.append(recived_tile)
				recived_tile.selection_ok()
				if attempt_len > 0:
					#assegno look_forward per avere memoria di dove prosegue il path
					attempt_tiles[-2].look_forward = attempt_tiles[-1].grid_vect - attempt_tiles[-2].grid_vect
				
				attempt_changed.emit(not selected, letter)


func set_answer(result: AttemptResult, word: String) -> void:
	var color
	match result:
		AttemptResult.WRONG:
			color = Color(1, 0.6, 0.6)
		AttemptResult.NEW_FIND:
			color = Color(0.6, 1, 0.6)
		AttemptResult.REPEATED:
			color = Color(0.6, 0.6, 0.6)
		AttemptResult.BONUS:
			color = Color.LIGHT_SEA_GREEN
	
	path.default_color = color
	ready_for_attempt = false
	valid_attempt = false
	get_tree().call_group("tiles_group", "set_result", result, word, color)
	# aspetto il tempo di mostrare il risultato
	$Timer.start()


func _on_rotate_clockwise_pressed() -> void:
	rot_on = 1 if rot_on == 0 else rot_on;
	ready_for_attempt = false;


func _on_rotate_counter_clockwise_pressed() -> void:
	rot_on = -1 if rot_on == 0 else rot_on;
	ready_for_attempt = false;


func show_path(grid_coords: Array) -> void:
	if rot_on == 0:
		path.default_color = Color(0.3, 0.5, 1)
		for i_coord in grid_coords:
			var i_tile = tiles[i_coord.x][i_coord.y]
			path.mod_add_point(i_tile.position + i_tile.size / 2 + $GridContainer.position)


func _on_progress_bar_initials_threshold_signal() -> void:
	number_shown = true


func _on_timer_timeout() -> void:
	attempt_tiles.clear()
	path.mod_clear_points()
	get_tree().call_group("tiles_group", "clear", yesterday_mode)
	get_tree().call_group("tiles_group", "show_number", number_shown and not yesterday_mode)
	clear.emit()
		
	ready_for_attempt = not yesterday_mode

func set_yesterday_mode() -> void:
	yesterday_mode = true
