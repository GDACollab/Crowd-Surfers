extends Control

@onready var timerDisplay: RichTextLabel = $"Timer BG/Timer Text"
	
func set_timer_text(value: String):
	timerDisplay.text = value
