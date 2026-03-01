extends Control

@onready var level_clear_ui: Control = $PhoneImage/MainContainer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
func _on_restart_button_pressed() -> void:
	SceneFadeTransition.transition_to_scene(load(get_tree().current_scene.scene_file_path))
	get_tree().paused = false
	queue_free()
	
func _on_continue_button_pressed() -> void:
	SceneFadeTransition.transition_to_scene(load("res://Scenes/UI Menus/MainMenu/MainMenu.tscn"))
	await get_tree().create_timer(SceneFadeTransition.FADE_TIME - 0.1).timeout 
	get_tree().paused = false
