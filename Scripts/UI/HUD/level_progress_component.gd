extends Control
## Level_Progress_Component

@onready var bar: TextureProgressBar = $"Progress Bar"

func set_Progress(value: float):
	bar.value = value
