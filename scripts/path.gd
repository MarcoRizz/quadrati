extends Line2D

@export var r_circle := 32

func mod_add_point(coords: Vector2) -> void:
	add_point(coords)
	queue_redraw()


func mod_remove_point(index: int) -> void:
	remove_point(index)
	queue_redraw()


func mod_clear_points() -> void:
	clear_points()
	queue_redraw()


func _draw() -> void:
	for coords in points:
		draw_circle(coords, r_circle, default_color)


func _on_grid_clear_grid() -> void:
	mod_clear_points()
	default_color = Color(1, 1, 0)
