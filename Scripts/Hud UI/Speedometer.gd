extends Control

signal speed_changed(new_speed: float)

@onready var bar: TextureProgressBar = $TextureProgressBar

func set_speed(value: float):
	bar.value = value
	emit_signal("speed_changed", value)
