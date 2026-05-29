extends ScrollContainer

@export var scroll_speed: float = 1000

var has_control_focus: bool = false

func _ready() -> void:
	$VBoxContainer/BackButton.grab_focus.call_deferred()

func _process(delta: float) -> void:
	var scroll_input: float = Input.get_axis("ui_up", "ui_down")
	
	if not is_zero_approx(scroll_input):
		scroll_vertical += int(scroll_input * delta * scroll_speed)
