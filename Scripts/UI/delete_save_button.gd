extends "res://Scripts/UI/button_highlight.gd"

@export var required_hold_time: float = 2

var hold_time: float = 0
signal button_hold_finished

func _process(delta: float) -> void:
	# Update hold_time
	if button_pressed:
		hold_time += delta
	else:
		hold_time -= delta * 2
	
	# Clamp hold_time or emit signal if done
	if hold_time < 0:
		hold_time = 0
	elif hold_time >= required_hold_time:
		button_hold_finished.emit()
		hold_time = 0
	
	#print(hold_time)
