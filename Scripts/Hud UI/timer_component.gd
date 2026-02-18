extends Control

signal time_changed(new_time: String)

@onready var timerDisplay: Label = $Timer/Text

func set_time(value: float):
	var formatted_time = str(value)
	timerDisplay.text = formatted_time
	time_changed.emit(formatted_time)
