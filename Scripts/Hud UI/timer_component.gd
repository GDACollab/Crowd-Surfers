extends Control

@onready var timerDisplay: Label = $Timer/Text

func set_time(value: float):
	var formatted_time = str(value)
	timerDisplay.text = formatted_time
	#print("Done at set_time")
	
func _ready() -> void:
	#print("Testing signal at timer")
	#set_time(5.0)
	pass
