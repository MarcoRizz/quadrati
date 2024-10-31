extends Button

# Variabili per il click delle parole
const max_holding_time = 1.0 #secondi
var clicked_label
var click_global_position
var max_mouse_move = 10.0 #se sto trascinando il Panel evito che continui a cliccare la parola
var holding_click_delta_time

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
