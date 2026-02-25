extends Control

signal time_changed(new_speed: float)

@onready var timerDisplay: Label = $Timer/Text

func set_time(value: float):
	var value_Int = int(value)
	var floating_Points = snapped((value - value_Int) * 100,0)
	var formatted_time = str(value_Int) + ":" + str(floating_Points)
	timerDisplay.text = formatted_time
	
