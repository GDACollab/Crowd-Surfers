extends Control


func _on_vertical_slice_button_pressed() -> void:
	SceneFadeTransition.transition_to_scene_with_loading("res://Scenes/Levels/AllTogetherNOW!!!!.tscn")
	
func _on_parking_lot_button_pressed() -> void:
	SceneFadeTransition.transition_to_scene_with_loading("res://Scenes/Levels/reference_scene.tscn")
