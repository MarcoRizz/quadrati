extends PanelContainer

@onready var label_obj = $MarginContainer/Time
@onready var tentativi_obj = $MarginContainer/Tentativi

var time: float = 0.0
var mins: int = 0
var secs: int = 0
var hours: int = 0

var attempts_n: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
	secs = int(fmod(time, 60))
	mins = int(fmod(time, 3600) / 60)
	hours = int(fmod(time, 86400) / 3600)
	
	if hours == 0:
		label_obj.text = "%02d:%02d" % [mins, secs]
	else:
		label_obj.text = "%02dh%02d:%02d" % [hours, mins, secs]


func set_attempts(value: int) -> void:
	attempts_n = value
	tentativi_obj.text = "T:%03d" % attempts_n


func add_attempt(_result, word) -> void:
	if word.length() > 3:
		set_attempts(attempts_n + 1)

func set_yesterday_mode() -> void:
	set_process(false)
