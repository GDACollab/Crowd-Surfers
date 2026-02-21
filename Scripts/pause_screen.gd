extends Control

@onready var phone_animation_player : AnimationPlayer = $PhoneBackground/AnimationPlayer

@onready var controls_container: VBoxContainer = $PhoneBackground/ControlsContainer
@onready var button_container: VBoxContainer = $PhoneBackground/ButtonContainer

var rotating: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	queue_free()

func _on_controls_button_pressed() -> void:
	if (rotating):
		return
	
	rotating = true
	controls_container.visible = true
	button_container.visible = false
	phone_animation_player.play("rotate_landscape")

func _on_back_button_pressed() -> void:
	if (rotating):
		return
		
	rotating = true
	controls_container.visible = false
	button_container.visible = true
	phone_animation_player.play("rotate_portrait")

func _on_restart_level_button_pressed() -> void:
	SceneFadeTransition.transition_to_scene(load(get_tree().current_scene.scene_file_path))
	get_tree().paused = false
	queue_free()

# Called by animation player
func stop_rotating() -> void:
	rotating = false
