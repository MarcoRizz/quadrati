extends Label

@onready var timer_obj: Timer = $PanelBonus/TimerBonus
@onready var panel_bonus_obj: PanelContainer = $PanelBonus


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_grid_attempt_changed(add_char: bool, letter: String) -> void:
	if add_char:
		text += letter
	else:
		text = text.erase(text.length() - 1, 1)


func _on_grid_clear() -> void:
	text = ""


func _on_panel_bonus_visibility_changed() -> void:
	if panel_bonus_obj.visible:
		timer_obj.start()


func _on_timer_bonus_timeout() -> void:
	panel_bonus_obj.hide()
