extends Node2D

const node_tile = preload("res://tile.tscn")
const tile_size := 90.0
const tile_spacing := 10.0

const grid_size := 4

var valid_clic: bool = false #lo utilizzo per capire se ho iniziato a cliccare una
#tile, dal momento che le tile successive vengono selezionate solo col passaggio del mouse

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
			var tile = node_tile.instantiate()
			add_child(tile)
			tile.grid_x = x
			tile.grid_y = y
			#ridimensiono in un tile_size x tile_size e posiziono
			tile.scale.x = tile_size / tile.texture.get_width()
			tile.scale.y = tile_size / tile.texture.get_height()
			tile.position = elaborate_tile_coordinate(x, y)
			
			#assegno le lettere
			var letter_obj = tile.get_node("Label")
			letter_obj.text = json_as_dict.today.grid[y][x]
			tile.selection.connect(on_tile_selection)

func _input(event):
	if event is InputEventMouseButton:
		if event.is_action_released("clic"):
			valid_clic = false
			get_node("Line2D").clear_points()

func on_tile_selection(grid_x, grid_y, letter):
	valid_clic = true
	get_node("Line2D").add_point(elaborate_tile_coordinate(grid_x, grid_y))
	print("selection " + letter)
	print("position: " + str(grid_x) + ", " + str(grid_y))

func elaborate_tile_coordinate(grid_x: int, grid_y: int) -> Vector2:
	return Vector2((tile_size + tile_spacing) * (grid_x + 1.0/2), (tile_size + tile_spacing) * (grid_y + 1.0/2))
