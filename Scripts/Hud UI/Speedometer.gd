extends Control

@onready var bar: TextureProgressBar = $TextureProgressBar

@export var bar_value_change_speed_per_second: float = 900.0

var target_speed: float

func _process(delta: float):
	if (bar.value < target_speed):
		bar.value += bar_value_change_speed_per_second * delta
		bar.value = min(bar.value, target_speed)
	else:
		bar.value -= bar_value_change_speed_per_second * delta
		bar.value = max(bar.value, target_speed)
			
func set_speed(value: float):
	target_speed = value

func set_max_speed(value:float):
	bar.max_value = value
	
