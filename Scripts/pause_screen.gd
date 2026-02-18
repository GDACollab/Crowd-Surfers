extends Control

func _on_resume_button_pressed() -> void:
	print("hi")
	Engine.time_scale = 1.0
	queue_free()
