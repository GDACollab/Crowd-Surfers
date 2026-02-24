extends Control

#signal speed_changed(new_speed: float)

@onready var bar: TextureProgressBar = $TextureProgressBar

func set_speed(value: float):
	bar.value = value
	#print("SpeedValue is now: ", bar.value, " max speed is: ", bar.max_value)
	#speed_changed.emit(value)

func set_Max_Speed(value:float):
	bar.max_value = value
	#print("MAX SPEED FROM SPEED IS" , bar.max_value)
	pass
