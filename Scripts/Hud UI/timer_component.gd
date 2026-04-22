extends Control

@onready var mainTimerDisplay: RichTextLabel = $"Timer BG/Main Timer Text"
@onready var centisecondsTimerDisplay: RichTextLabel = $"Timer BG/Centiseconds Timer Text"

func set_timer_text(mainTimer: String, centisecondsTimer: String):
	mainTimerDisplay.text = mainTimer
	centisecondsTimerDisplay.text = centisecondsTimer
