extends Control
## Level_Progress_Component

@onready var bar: ProgressBar = $"Level Progress"

func set_Progress(value: float):
	bar.value = value
