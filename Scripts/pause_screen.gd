extends Control

@onready var phone_animation_player : AnimationPlayer = $PhoneBackground/AnimationPlayer

@onready var controls_container: VBoxContainer = $PhoneBackground/ControlsContainer
@onready var buttons_container: VBoxContainer = $PhoneBackground/ButtonContainer
@onready var settings_scene: Control = $PhoneBackground/SettingsScene

var transitioning: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	queue_free()

func _on_controls_button_pressed() -> void:
	if (transitioning):
		return
	
	transitioning = true
	controls_container.visible = true
	settings_scene.visible = false
	phone_animation_player.play("rotate_landscape")

func _on_controls_back_button_pressed() -> void:
	if (transitioning):
		return
		
	transitioning = true
	buttons_container.visible = true
	phone_animation_player.play("rotate_portrait")
	
func _on_settings_button_pressed() -> void:
	if (transitioning):
		return
	
	transitioning = true
	settings_scene.visible = true
	phone_animation_player.play("open_settings")
	
func _on_settings_back_button_pressed() -> void:
	if (transitioning):
		return
		
	transitioning = true
	buttons_container.visible = true
	phone_animation_player.play_backwards("open_settings")

func _on_restart_level_button_pressed() -> void:
	SceneFadeTransition.transition_to_scene(load(get_tree().current_scene.scene_file_path))
	get_tree().paused = false
	queue_free()

func _on_exit_level_button_pressed() -> void:
	SceneFadeTransition.transition_to_scene(load("res://Scenes/UI Menus/MainMenu/MainMenu.tscn"))
	await get_tree().create_timer(SceneFadeTransition.FADE_TIME - 0.1).timeout 
	get_tree().paused = false
	
# Following functions called by animation player
func stop_transitioning() -> void:
	transitioning = false
	
func start_transitioning() -> void:
	transitioning = true
	
func hide_buttons() -> void:
	buttons_container.visible = false
	
func hide_controls() -> void:
	controls_container.visible = false
	
