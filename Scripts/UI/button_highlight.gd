extends TextureButton

@export var brightness_change: float = 0.2
@export var focus_brightness_change: float = 0.2

var current_brightness: float = 0

func _on_mouse_entered() -> void:
	if (self.disabled == true):
		return
		
	set_brightness(brightness_change)

func _on_mouse_exited() -> void:
	if (self.disabled == true):
		return
		
	set_brightness(0)


func _on_focus_entered() -> void:
	if (self.disabled == true):
		return
		
	set_brightness(focus_brightness_change)

func _on_focus_exited() -> void:
	if (self.disabled == true):
		return
		
	set_brightness(0)
	
func set_brightness(brightness: float) -> void:
	var difference: float = brightness - current_brightness
	current_brightness = brightness
	
	modulate.r += difference
	modulate.g += difference
	modulate.b += difference
