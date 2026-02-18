extends Control

@onready var controls_container: VBoxContainer = $ControlsContainer
@onready var button_container: VBoxContainer = $ButtonContainer

func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	queue_free()

func _on_controls_button_pressed() -> void:
	controls_container.visible = true
	button_container.visible = false

func _on_back_button_pressed() -> void:
	controls_container.visible = false
	button_container.visible = true
