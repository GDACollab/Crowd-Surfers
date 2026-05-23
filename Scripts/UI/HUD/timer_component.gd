extends Control

@onready var mainTimerDisplay: RichTextLabel = $"Timer BG/Main Timer Text"
@onready var centisecondsTimerDisplay: RichTextLabel = $"Timer BG/Centiseconds Timer Text"
var textureDict : Dictionary = {
	"0" : preload("res://Assets/Art/UI/HUD/TimerNumbers/0.png"),
	"1" : preload("res://Assets/Art/UI/HUD/TimerNumbers/1.png"),
	"2" : preload("res://Assets/Art/UI/HUD/TimerNumbers/2.png"),
	"3" : preload("res://Assets/Art/UI/HUD/TimerNumbers/3.png"),
	"4" : preload("res://Assets/Art/UI/HUD/TimerNumbers/4.png"),
	"5" : preload("res://Assets/Art/UI/HUD/TimerNumbers/5.png"),
	"6" : preload("res://Assets/Art/UI/HUD/TimerNumbers/6.png"),
	"7" : preload("res://Assets/Art/UI/HUD/TimerNumbers/7.png"),
	"8" : preload("res://Assets/Art/UI/HUD/TimerNumbers/8.png"),
	"9" : preload("res://Assets/Art/UI/HUD/TimerNumbers/9.png"),
	":" : preload("res://Assets/Art/UI/HUD/TimerNumbers/colon.png"),
	"." : preload("res://Assets/Art/UI/HUD/TimerNumbers/period.png")
 }

func set_timer_text(mainTimer: String, centisecondsTimer: String):
	## Clear current text
	mainTimerDisplay.clear()
	centisecondsTimerDisplay.clear()

	## Add text images
	for m in mainTimer:
		mainTimerDisplay.add_image(textureDict[m])
	for c in centisecondsTimer:
		centisecondsTimerDisplay.add_image(textureDict[c])
