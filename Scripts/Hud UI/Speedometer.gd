extends Control

@onready var bar: TextureProgressBar = $TextureProgressBar

func set_speed(value: float):
	bar.value = value

func set_max_speed(value:float):
	bar.max_value = value
