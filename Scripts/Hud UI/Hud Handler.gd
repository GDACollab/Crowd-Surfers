extends Control

@onready var speedometer = $"HBoxContainer/SpeedOmeter Component"
@onready var timerDisplay = $"HBoxContainer/VBoxContainer/Timer Component"

# Get reference without actually editing the player script
@onready var player = get_parent().get_node("Player")

func _ready():
	speedometer.speed_changed.connect(_on_speed_changed)
	timerDisplay.time_changed.connect(_on_time_changed)
	print(player)

func _on_speed_changed(new_speed: float):
	print("Speed updated to:", new_speed)
	
func _on_time_changed(new_time: String):
	print("time updated to: ", new_time)
	
func _process(delta: float) -> void:
	pass
