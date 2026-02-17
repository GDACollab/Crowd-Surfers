extends Control

signal time_changed(new_speed: float)

@onready var timerDisplay: Label = $Timer/Text

func set_speed(value: float):
	timerDisplay.text = str(value)
	emit_signal("time_changed", value)
