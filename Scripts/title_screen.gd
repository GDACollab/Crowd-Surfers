extends Control

func _on_credits_button_pressed() -> void:
	SceneFadeTransition.transition_to_scene_with_loading("res://Scenes/UI Menus/Credits/credits.tscn")
