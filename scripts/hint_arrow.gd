extends Node2D

var center: Vector2 = Vector2(40, 40)
var direction: Vector2 = Vector2(1, 0)
var color: Color = Color.BISQUE

func _draw() -> void:
	var unit = 14
	var L = 45
	
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

func redraw(new_center: Vector2, new_direction: Vector2, new_color: Color) -> void:
	center = new_center
	direction = new_direction
	color = new_color
	queue_redraw()
