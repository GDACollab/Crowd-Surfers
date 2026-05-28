extends Control

@onready var phone_animation_player : AnimationPlayer = $PhoneOutline/PhoneBackground/AnimationPlayer

@onready var controls_container: Control = $PhoneOutline/PhoneBackground/ControlsContainer
@onready var buttons_container: Control = $PhoneOutline/PhoneBackground/ButtonContainer
@onready var settings_scene: Control = $PhoneOutline/PhoneBackground/SettingsScene

var transitioning: bool = false

enum PauseScreenPage {
	SETTINGS = 1,
	BUTTONS = 2,
	CONTROLS = 3
}
var page: PauseScreenPage = PauseScreenPage.BUTTONS

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func _on_resume_button_pressed() -> void:
	if (transitioning or page != PauseScreenPage.BUTTONS):
		return
		
	Audio.set_level_audio_state(false)
	get_tree().paused = false
	queue_free()

func _on_controls_button_pressed() -> void:
	if (transitioning or page != PauseScreenPage.BUTTONS):
		return
	
	start_transitioning()
	controls_container.visible = true
	page = PauseScreenPage.CONTROLS
	phone_animation_player.play("rotate_landscape")

func _on_controls_back_button_pressed() -> void:
	if (transitioning or page != PauseScreenPage.CONTROLS):
		return
		
	start_transitioning()
	page = PauseScreenPage.BUTTONS
	phone_animation_player.play("rotate_portrait")
	
func _on_settings_button_pressed() -> void:
	if (transitioning or page != PauseScreenPage.BUTTONS):
		return
	
	start_transitioning()
	settings_scene.visible = true
	page = PauseScreenPage.SETTINGS
	phone_animation_player.play("open_settings")
	
func _on_settings_back_button_pressed() -> void:
	if (transitioning or page != PauseScreenPage.SETTINGS):
		return
		
	start_transitioning()
	page = PauseScreenPage.BUTTONS
	phone_animation_player.play("close_settings")
	
	SaveDataManager.save_data()

func _on_restart_level_button_pressed() -> void:
	if (transitioning or page != PauseScreenPage.BUTTONS):
		return
		
	Audio.set_level_audio_state(false)
	SceneFadeTransition.transition_to_scene(load(get_tree().current_scene.scene_file_path))
	start_transitioning()

func _on_exit_level_button_pressed() -> void:
	if (transitioning or page != PauseScreenPage.BUTTONS):
		return
		
	Audio.set_level_audio_state(false)
	SceneFadeTransition.transition_to_scene(load("res://Scenes/UI Menus/MainMenu/MainMenu.tscn"))
	start_transitioning()
		
# Following functions called by animation player
func stop_transitioning() -> void:
	transitioning = false
	
	match page:
		PauseScreenPage.SETTINGS:
			settings_scene.visible = true
			buttons_container.visible = false
			controls_container.visible = false
			
		PauseScreenPage.BUTTONS:
			settings_scene.visible = false
			buttons_container.visible = true
			controls_container.visible = false
			
		PauseScreenPage.CONTROLS:
			settings_scene.visible = false
			buttons_container.visible = false
			controls_container.visible = true

	
func start_transitioning() -> void:
	buttons_container.visible = true
			
	transitioning = true
