extends Control

@onready var act_1_button: TextureButton = $OrdersBody/ScrollContainer/VBoxContainer/Act1Button
@onready var act_2_button: TextureButton = $OrdersBody/ScrollContainer/VBoxContainer/Act2Button
@onready var act_3_button: TextureButton = $OrdersBody/ScrollContainer/VBoxContainer/Act3Button

func _ready() -> void:
	var best_time_1: RichTextLabel = act_1_button.get_child(1)
	var best_time_2: RichTextLabel = act_2_button.get_child(1)
	var best_time_3: RichTextLabel = act_3_button.get_child(1)
	
	best_time_1.text = "[i]Best Time: " + get_formatted_timer_text(SaveDataManager.level_times[0]) + " "
	best_time_2.text = "[i]Best Time: " + get_formatted_timer_text(SaveDataManager.level_times[1]) + " "
	best_time_3.text = "[i]Best Time: " + get_formatted_timer_text(SaveDataManager.level_times[2]) + " "
	
	# story locking here
	
func _on_act_1_button_pressed() -> void:
	_kill_hub_music()
	Story.next_scene = "res://Scenes/Levels/LevelOne.tscn"
	Story.selected_level = 0
	SceneFadeTransition.transition_to_scene_with_loading("res://Scenes/UI Menus/level_dialogue_player.tscn")

func _on_act_2_button_pressed() -> void:
	_kill_hub_music()
	Story.next_scene = "res://Scenes/Levels/Full Levels/lvl_concept_stage_2.tscn"
	Story.selected_level = 1
	SceneFadeTransition.transition_to_scene_with_loading("res://Scenes/UI Menus/level_dialogue_player.tscn")

func _on_act_3_button_pressed() -> void:
	_kill_hub_music()
	Story.next_scene = "res://Scenes/Levels/ActThreeConcept.tscn"
	Story.selected_level = 2
	SceneFadeTransition.transition_to_scene_with_loading("res://Scenes/UI Menus/level_dialogue_player.tscn")

func _kill_hub_music():
	if (Audio.registry.has("mus_hub")):
		Audio.kill_persistent("mus_hub")

# Copied directly from Hud Handler.gd cause i cant be asked to make good code the day of release lol
func get_formatted_timer_text(time: float) -> String:
	var rounded_time: float = snapped(time, 0.01)
	var seconds: String = str(int(rounded_time) % 60)
	if (seconds.length() == 1):
		seconds = "0" + seconds
		
	var minutes: String = str(int(rounded_time / 60))
	if (minutes.length() == 1):
		minutes = "0" + minutes
		
	var centi_seconds: String = str(int((rounded_time - int(rounded_time)) * 100))
	if (centi_seconds.length() == 1):
		centi_seconds += "0"
		
	var formatted_time: String = minutes + ":" + seconds + "." + str(centi_seconds)
	
	return formatted_time
