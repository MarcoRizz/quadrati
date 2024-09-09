extends Node2D

const node_tile = preload("res://tile.tscn")
const myenums = preload("res://enum.gd")

@export var tile_size := 90.0
@export var tile_spacing := 10.0

const grid_size := 4
@onready var path: Line2D = $Path/Line2D

var tiles = [[node_tile, node_tile, node_tile, node_tile],
			 [node_tile, node_tile, node_tile, node_tile],
			 [node_tile, node_tile, node_tile, node_tile],
			 [node_tile, node_tile, node_tile, node_tile]]

var attempt = {"letter": [], "xy": []}
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
			tiles[x][y] = node_tile.instantiate()
			add_child(tiles[x][y])
			tiles[x][y].grid_x = x
			tiles[x][y].grid_y = y
			#ridimensiono in un tile_size x tile_size e posiziono
			tiles[x][y].scale.x = tile_size / tiles[x][y].texture.get_width()
			tiles[x][y].scale.y = tile_size / tiles[x][y].texture.get_height()
			tiles[x][y].position = elaborate_tile_coordinate(x, y)
			
			#assegno le lettere
			var letter_obj = tiles[x][y].get_node("Label")
			letter_obj.text = json_as_dict.today.grid[y][x]
			tiles[x][y].selection.connect(on_tile_selection)

func _input(event):
	if event is InputEventMouseButton:
		if event.is_action_released("clic"):
			path.clear_points()
			print(attempt)
			attempt.letter.clear()
			attempt.xy.clear()

func on_tile_selection(grid_x, grid_y, letter):
	print("selection " + letter)
	print("position: " + str(grid_x) + ", " + str(grid_y))
	
	#capisco se sto tornando indietro o progredendo
	var attempt_len = len(attempt.xy)
	if len(attempt.xy) > 1 and attempt.xy[-2].x == grid_x and attempt.xy[-2].y == grid_y:
		#undo ultima selezione
		path.remove_point(path.get_point_count() - 1)
		i_tile_from_attempt(-1).undo()
		i_tile_from_attempt(-1).state = Constants.state.SELECTABLE
		attempt.letter.resize(attempt_len - 1)
		attempt.xy.resize(attempt_len - 1)
		i_tile_from_attempt(-1).state = Constants.state.SELECTED
		if len(attempt.xy) > 1:
			i_tile_from_attempt(-2).state = Constants.state.SELECTABLE
	else:
		#aggiungo selezione
		if len(attempt.xy) > 0:
			i_tile_from_attempt(-1).state = Constants.state.SELECTABLE
		if len(attempt.xy) > 1:
			i_tile_from_attempt(-2).state = Constants.state.SELECTED
		path.add_point(elaborate_tile_coordinate(grid_x, grid_y))
		attempt.letter.append(letter)
		attempt.xy.append(Vector2(grid_x, grid_y))
	
	#riassegno gli stati alle tile
	if len(attempt.xy) > 1:
		i_tile_from_attempt(-2).state = Constants.state.SELECTABLE #il penultimo deve diventare selezionabile per l'undo
	for y in range(grid_size):
		for x in range(grid_size):
			if x - grid_x <= 1 and x - grid_x >= -1 and y - grid_y <= 1 and y - grid_y >= -1 and not tiles[x][y].state == Constants.state.SELECTED:
				tiles[x][y].state = Constants.state.SELECTABLE
			elif not tiles[x][y].state == Constants.state.SELECTED:
				tiles[x][y].state = Constants.state.UNSELECTABLE

func elaborate_tile_coordinate(grid_x: int, grid_y: int) -> Vector2:
	return Vector2((tile_size + tile_spacing) * (grid_x + 1.0/2), (tile_size + tile_spacing) * (grid_y + 1.0/2))

func i_tile_from_attempt(i: int) -> Sprite2D:
	return tiles[attempt.xy[i].x][attempt.xy[i].y]
