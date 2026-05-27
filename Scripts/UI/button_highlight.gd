extends TextureButton

@export var brightness_change: float = 0.2


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
