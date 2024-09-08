extends Node2D

const node_tile = preload("res://tile.tscn")
const tile_size := 90.0
const tile_spacing := 10.0

const grid_size := 4

var valid_clic = false

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
			#ridimensiono in un tile_size x tile_size e posiziono
			tile.scale.x = tile_size / tile.texture.get_width()
			tile.scale.y = tile_size / tile.texture.get_height()
			tile.position = Vector2((tile_size + tile_spacing) * x + tile_spacing / 2, (tile_size + tile_spacing) * y + tile_spacing / 2)
			
			#assegno le lettere
			var letter_obj = tile.get_child(0)
			letter_obj.text = json_as_dict.today.grid[y][x]
