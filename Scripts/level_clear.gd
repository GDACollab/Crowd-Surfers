extends Control

@export var hud_ui: Control
@export var level_number: int

@onready var clear_time_text: Label = $Background/ClearTimeText
@onready var best_time_text: Label = $Background/BestTimeText

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
func _on_restart_button_pressed() -> void:
	SceneFadeTransition.transition_to_scene(load(get_tree().current_scene.scene_file_path))
	get_tree().paused = false
	queue_free()
	
func _on_continue_button_pressed() -> void:
	Story.post_level = true
	Story.next_scene = "res://Scenes/UI Menus/MainMenu/MainMenu.tscn"
	SceneFadeTransition.transition_to_scene(load("res://Scenes/UI Menus/level_dialogue_player.tscn"))
	await get_tree().create_timer(SceneFadeTransition.FADE_TIME - 0.1).timeout 
	get_tree().paused = false

func open_ui() -> void:
	#don't adjust save file if not assigned
	if level_number > 0:
		SaveDataManager.levels_complete[level_number-1] = true
		#level times being 0.0 means the level has no set time
		if hud_ui.curr_Time < SaveDataManager.level_times[level_number-1] or SaveDataManager.level_times[level_number-1] == 0.0:
			SaveDataManager.level_times[level_number-1] = hud_ui.curr_Time
		SaveDataManager.save_data()
		
	clear_time_text.text = hud_ui.get_Formatted_Timer_Text(hud_ui.curr_Time, false, false) + hud_ui.get_Formatted_Timer_Text(hud_ui.curr_Time, true, false)
	if level_number > 0:
		best_time_text.text = hud_ui.get_Formatted_Timer_Text(SaveDataManager.level_times[level_number-1], false, false) + hud_ui.get_Formatted_Timer_Text(SaveDataManager.level_times[level_number-1], true, false)
