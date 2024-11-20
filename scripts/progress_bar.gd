extends ProgressBar

signal initials_threshold_signal

@onready var progress_points_obj: Label = $CenterContainer/HBoxContainer/ProgressPoints
@onready var progress_bonus_points_obj: Label = $CenterContainer/HBoxContainer/ProgressBonusPoints

var initials_threshold = false
var bonus_points = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func increase(amount: int) -> void:
	value += amount
	update_labels()
	
	if not initials_threshold and value * 3.0 > max_value * 1.0:
		initials_threshold = true
		initials_threshold_signal.emit()


func increase_max_value(amount: int) -> void:
	max_value += amount
	update_labels()

func increase_bonus(amount: int) -> void:
	max_value += amount
	bonus_points += amount
	increase(amount)

func reset():
	max_value = 0
	value = 0
	bonus_points = 0
	initials_threshold = false
	update_labels()

func update_labels():
	progress_points_obj.text = "%01d/%01d" % [value - bonus_points, max_value - bonus_points]
	progress_bonus_points_obj.text = "+ (%01d)" % bonus_points
	
	progress_bonus_points_obj.visible = not bonus_points == 0
