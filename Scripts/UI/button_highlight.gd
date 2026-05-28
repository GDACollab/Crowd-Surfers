extends TextureButton

@export var brightness_change: float = 0.2
@export var focus_brightness_change: float = 0.2


func _on_mouse_entered() -> void:
	if (self.disabled == true):
		return
		
	modulate.r += brightness_change
	modulate.g += brightness_change
	modulate.b += brightness_change

func _on_mouse_exited() -> void:
	if (self.disabled == true):
		return
		
	modulate.r -= brightness_change
	modulate.g -= brightness_change
	modulate.b -= brightness_change


func _on_focus_entered() -> void:
	if (self.disabled == true):
		return
		
	modulate.r += focus_brightness_change
	modulate.g += focus_brightness_change
	modulate.b += focus_brightness_change

func _on_focus_exited() -> void:
	if (self.disabled == true):
		return
		
	modulate.r -= focus_brightness_change
	modulate.g -= focus_brightness_change
	modulate.b -= focus_brightness_change
