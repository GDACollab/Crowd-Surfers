extends Control

@onready var timerDisplay: Label = $"Timer BG/Timer Text"
	
func set_timer_text(value: String):
	timerDisplay.text = value
