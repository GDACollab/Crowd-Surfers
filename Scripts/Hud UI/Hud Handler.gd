extends Control

@onready var speedometer = $"HBoxContainer/SpeedOmeter Component"
@onready var timerDisplay = $"HBoxContainer/VBoxContainer/Timer Component"
func _ready():
	speedometer.speed_changed.connect(_on_speed_changed)
	timerDisplay.timer_changed.connect(_on_time_changed)

func _on_speed_changed(new_speed: float):
	print("Speed updated to:", new_speed)
	
func _on_time_changed(new_time: String):
	print("time updated to: ", new_time)
