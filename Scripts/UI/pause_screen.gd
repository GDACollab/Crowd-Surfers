extends Control

@onready var phone_animation_player : AnimationPlayer = $PhoneOutline/PhoneBackground/AnimationPlayer

@onready var controls_container: Control = $PhoneOutline/PhoneBackground/ControlsContainer
@onready var buttons_container: Control = $PhoneOutline/PhoneBackground/ButtonContainer
@onready var settings_scene: Control = $PhoneOutline/PhoneBackground/SettingsScene

var transitioning: bool = false

var has_control_focus: bool = false

enum PauseScreenPage {
	SETTINGS = 1,
	BUTTONS = 2,
	CONTROLS = 3
}
var page: PauseScreenPage = PauseScreenPage.BUTTONS

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func _unhandled_input(event: InputEvent) -> void:
	# grab focus if a ui direction is used
	if (not has_control_focus and 
			(event.is_action("ui_up") or event.is_action("ui_down") or 
			 event.is_action("ui_left") or event.is_action("ui_right"))):
		has_control_focus = true
		var node_to_focus: Control
		match page:
			PauseScreenPage.SETTINGS:
				node_to_focus = settings_scene.get_node("SettingsBody/BackButton")
			PauseScreenPage.BUTTONS:
				node_to_focus = buttons_container.get_node("ResumeButton")
			PauseScreenPage.CONTROLS:
				node_to_focus = controls_container.get_node("BackButton")
		node_to_focus.grab_focus()
	
	# Back button behavior
	if event.is_action_pressed("ui_back"):
		var button_to_trigger: BaseButton
		match page:
			PauseScreenPage.SETTINGS:
				button_to_trigger = settings_scene.get_node("SettingsBody/BackButton")
			PauseScreenPage.BUTTONS:
				button_to_trigger = buttons_container.get_node("ResumeButton")
			PauseScreenPage.CONTROLS:
				button_to_trigger = controls_container.get_node("BackButton")
		button_to_trigger.pressed.emit()

func _on_resume_button_pressed() -> void:
	if (transitioning or page != PauseScreenPage.BUTTONS):
		return
		
	Audio.toggle_level_audio()
	get_tree().paused = false
	queue_free()

func _on_controls_button_pressed() -> void:
	if (transitioning or page != PauseScreenPage.BUTTONS):
		return
	
	start_transitioning()
	controls_container.visible = true
	page = PauseScreenPage.CONTROLS
	phone_animation_player.play("rotate_landscape")
	
	buttons_container.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_DISABLED
	has_control_focus = false

func _on_controls_back_button_pressed() -> void:
	if (transitioning or page != PauseScreenPage.CONTROLS):
		return
		
	start_transitioning()
	page = PauseScreenPage.BUTTONS
	phone_animation_player.play("rotate_portrait")
	
	buttons_container.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_INHERITED
	has_control_focus = false
	
func _on_settings_button_pressed() -> void:
	if (transitioning or page != PauseScreenPage.BUTTONS):
		return
	
	Audio.toggle_level_audio()
	start_transitioning()
	settings_scene.visible = true
	page = PauseScreenPage.SETTINGS
	phone_animation_player.play("open_settings")
	
	buttons_container.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_DISABLED
	has_control_focus = false
	
func _on_settings_back_button_pressed() -> void:
	if (transitioning or page != PauseScreenPage.SETTINGS):
		return
		
	Audio.toggle_level_audio()
	start_transitioning()
	page = PauseScreenPage.BUTTONS
	phone_animation_player.play("close_settings")
	
	buttons_container.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_INHERITED
	has_control_focus = false
	
	SaveDataManager.save_data()

func _on_restart_level_button_pressed() -> void:
	if (transitioning or page != PauseScreenPage.BUTTONS):
		return
		
	Audio.toggle_level_audio()
	SceneFadeTransition.transition_to_scene(load(get_tree().current_scene.scene_file_path))
	start_transitioning()

func _on_exit_level_button_pressed() -> void:
	if (transitioning or page != PauseScreenPage.BUTTONS):
		return
		
	Audio.toggle_level_audio()
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
