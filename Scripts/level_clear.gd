extends Control

@export var hud_ui: Control

@onready var clear_time_text: Label = $Panel/ClearTimeText

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
func _on_restart_button_pressed() -> void:
	SceneFadeTransition.transition_to_scene(load(get_tree().current_scene.scene_file_path))
	get_tree().paused = false
	queue_free()
	
func _on_continue_button_pressed() -> void:
	SceneFadeTransition.transition_to_scene(load("res://Scenes/Dialogue Interface/dialogue_testing.tscn"))
	await get_tree().create_timer(SceneFadeTransition.FADE_TIME - 0.1).timeout 
	get_tree().paused = false

func open_ui() -> void:
	clear_time_text.text = "Clear Time: " + hud_ui.get_Formatted_Timer_Text(hud_ui.curr_Time)
