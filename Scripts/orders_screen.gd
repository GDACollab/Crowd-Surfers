extends Control


func _on_vertical_slice_button_pressed() -> void:
	SceneFadeTransition.transition_to_scene_with_loading("res://Scenes/Dialogue Interface/PreLevel1Dialogue.tscn")
	
func _on_parking_lot_button_pressed() -> void:
	SceneFadeTransition.transition_to_scene_with_loading("res://Scenes/Levels/reference_scene.tscn")

func _on_act_1_button_pressed() -> void:
	Story.next_scene = "res://Scenes/Levels/LevelOne.tscn"
	Story.selected_level = 0
	SceneFadeTransition.transition_to_scene_with_loading("res://Scenes/UI Menus/level_dialogue_player.tscn")

func _on_act_2_button_pressed() -> void:
	Story.next_scene = "res://Scenes/Levels/lvl_concept_stage_2.tscn"
	Story.selected_level = 1
	SceneFadeTransition.transition_to_scene_with_loading("res://Scenes/UI Menus/level_dialogue_player.tscn")

func _on_act_3_button_pressed() -> void:
	SceneFadeTransition.transition_to_scene_with_loading("res://Scenes/Levels/ActThreeConcept.tscn")
