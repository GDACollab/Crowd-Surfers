extends Control

@onready var bar: TextureProgressBar = $TextureProgressBar

func set_speed(value: float):
	bar.value = value

func set_Max_Speed(value:float):
	bar.max_value = value
