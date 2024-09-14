extends Line2D

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
	for coords in self.points:
		draw_circle(coords, 35, Color("ffff00"))
