extends Control

func _on_credits_button_pressed() -> void:
	SceneFadeTransition.transition_to_scene(load("res://Scenes/UI Menus/Credits/credits.tscn"))
s
