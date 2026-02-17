extends Control

func _on_exit_button_pressed() -> void:
	SceneFadeTransition.transition_to_scene(load("res://Scenes/UI Menus/TitleScreen.tscn"))
