extends Node2D

var word = String()
var grid_pos: Vector2
var center = Vector2(40, 40)
var direction = Vector2(1, 0)
var color = Color.BISQUE

func _draw() -> void:
	const  unit = 14
	const L = 45
	
	draw_circle(Vector2(0, 0), 32, Color.BISQUE)
	draw_polygon(PackedVector2Array([
		Vector2(0, unit),
		Vector2(L, unit),
		Vector2(L, 2*unit),
		Vector2(L + 2*unit, 0),
		Vector2(L, -2*unit),
		Vector2(L, -unit),
		Vector2(0, -unit)
	]),PackedColorArray([color]))
	
	draw_set_transform(-center)
	position = center
	rotation = direction.angle()

func place(new_center: Vector2, new_grid_pos: Vector2, new_direction: Vector2, new_word: String, new_color: Color = Color.BISQUE) -> void:
	center = new_center
	grid_pos = new_grid_pos
	direction = new_direction
	word = new_word
	color = new_color
	queue_redraw()
