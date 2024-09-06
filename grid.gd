extends Node2D

const node_tile = preload("res://tile.tscn")
const tile_size := 100.0
const tile_spacing := 20.0

const grid_size := 4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_grid()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func generate_grid():
	for x in range(grid_size):
		#var tile_coordinates := Vector2.ZERO
		for y in range(grid_size):
			var tile = node_tile.instantiate()
			add_child(tile)
			tile.position = Vector2((tile_size + tile_spacing) * x + tile_spacing / 2, (tile_size + tile_spacing) * y + tile_spacing / 2)
