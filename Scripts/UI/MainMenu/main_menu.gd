extends Control

@onready var orders_animation_player : AnimationPlayer = $OrdersAnimationPlayer
@onready var voicemails_animation_player : AnimationPlayer = $VoicemailsAnimationPlayer
@onready var settings_animation_player : AnimationPlayer = $SettingsAnimationPlayer
@onready var social_media_animation_player : AnimationPlayer = $SocialMediaAnimationPlayer

@onready var main_container: Control = $PhoneImage/PhoneBg/MainContainer
@onready var orders_scene: Control = $PhoneImage/PhoneBg/OrdersScene
@onready var voicemails_scene: Control = $PhoneImage/PhoneBg/VoicemailsScene
@onready var settings_scene: Control = $PhoneImage/PhoneBg/SettingsScene
@onready var social_media_scene: Control = $PhoneImage/PhoneBg/SocialMediaScene

@onready var orders_button: TextureButton = $PhoneImage/PhoneBg/MainContainer/OrdersButton
@onready var voicemails_button: TextureButton = $PhoneImage/PhoneBg/MainContainer/VoicemailsButton

@onready var backgrounds_farther: Control = $BackgroundsFarther
@onready var backgrounds_closer: Control = $BackgroundsCloser

@export var animation_time: float = 0.3

@export var background_move_radius_x: float = 5.0
@export var background_move_radius_y: float = 3.0
@export var background_acceleration_speed: float = 0.03
@export var background_max_speed: float = 0.3
@export var time_between_target_changes: float = 3
@export var far_background_move_percentage: float = 0.7

var transitioning: bool = false

var start_background_position: Vector2
var target_position: Vector2
var time: float
var velocity: Vector2
var hub_music: FmodEvent

enum MainMenuPage {
	MAIN = 1,
	ORDERS = 2,
	VOICEMAILS = 3,
	SETTINGS = 4,
	SOCIAL_MEDIA = 5,
	DIALOGUE = 6
}
var page: MainMenuPage = MainMenuPage.MAIN

func _ready() -> void:
	orders_scene.visible = false
	voicemails_scene.visible = false
	settings_scene.visible = false
	social_media_scene.visible = false

	start_background_position = backgrounds_closer.position
	time = time_between_target_changes
	
	# Start music
	if (!Audio.registry.has("mus_hub")):
		hub_music = Audio.create_persistent("mus_hub", "event:/MUS/hub")
		hub_music.start()
		
	else:
		Audio.unpause_persistent("mus_hub")
		
	Inky.DialogueStarted.connect(_on_dialogue_start)
	Inky.DialogueEnded.connect(_on_dialogue_end)
	
func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("ui_back")):
		$UIAudio.play_back_sound()
		match page:
			MainMenuPage.MAIN:
				_on_exit_button_pressed()
			MainMenuPage.ORDERS:
				_on_orders_back_button_pressed()
			MainMenuPage.VOICEMAILS:
				_on_voicemails_back_button_pressed()
			MainMenuPage.SETTINGS:
				_on_settings_back_button_pressed()
			MainMenuPage.SOCIAL_MEDIA:
				_on_social_media_back_button_pressed()
		
	time += delta
	if (time > time_between_target_changes):
		time = 0
		target_position = start_background_position + Vector2(randf_range(-1 * background_move_radius_x, background_move_radius_x), randf_range(-1 * background_move_radius_y, background_move_radius_y))
		
	velocity = velocity.lerp(target_position - backgrounds_closer.position, delta * background_acceleration_speed)
	if (velocity.length() > background_max_speed):
		velocity = velocity.normalized() * background_max_speed
	backgrounds_closer.position += velocity
	backgrounds_farther.position = start_background_position.lerp(backgrounds_closer.position, far_background_move_percentage)

func _on_dialogue_start() -> void:
	page = MainMenuPage.DIALOGUE
	
func _on_dialogue_end() -> void:
	page = MainMenuPage.VOICEMAILS
	
func _on_exit_button_pressed() -> void:
	SceneFadeTransition.transition_to_scene(load("res://Scenes/UI Menus/TitleScreen.tscn"))
	Audio.pause_persistent("mus_hub")

func _on_orders_button_pressed() -> void:
	if (transitioning):
		return
	
	orders_button.disabled = true
	orders_button.modulate = Color.WHITE
	orders_animation_player.play("open_orders")
	orders_scene.visible = true
	
	main_container.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_DISABLED
	
	page = MainMenuPage.ORDERS
	set_transitioning()
	
func _on_voicemails_button_pressed() -> void:
	if (transitioning):
		return
	
	voicemails_button.disabled = true
	voicemails_button.modulate = Color.WHITE
	voicemails_animation_player.play("open_voicemails")
	voicemails_scene.visible = true
	
	main_container.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_DISABLED
	
	page = MainMenuPage.VOICEMAILS
	set_transitioning()
	
func _on_settings_button_pressed() -> void:
	if (transitioning):
		return
		
	settings_animation_player.play("open_settings")
	settings_scene.visible = true
	
	main_container.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_DISABLED
	
	page = MainMenuPage.SETTINGS
	set_transitioning()
	
func _on_social_media_button_pressed() -> void:
	if (transitioning):
		return
		
	social_media_animation_player.play("open_social_media")
	social_media_scene.visible = true
	
	main_container.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_DISABLED
	
	page = MainMenuPage.SOCIAL_MEDIA
	set_transitioning()
	
#Signalled by back button inside orders scene
func _on_orders_back_button_pressed() -> void:
	if (transitioning):
		return
		
	orders_button.disabled = false
	orders_animation_player.play_backwards("open_orders")
	orders_animation_player.seek(animation_time * 0.8, true)
	
	main_container.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_INHERITED
	
	page = MainMenuPage.MAIN
	set_transitioning()
	
func _on_voicemails_back_button_pressed() -> void:
	if (transitioning):
		return
		
	voicemails_button.disabled = false
	voicemails_animation_player.play_backwards("open_voicemails")
	voicemails_animation_player.seek(animation_time * 0.8, true)
	
	main_container.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_INHERITED
	
	page = MainMenuPage.MAIN
	set_transitioning()

#Signalled by back button inside settings scene
func _on_settings_back_button_pressed() -> void:
	if (transitioning):
		return
		
	settings_animation_player.play_backwards("open_settings")
	settings_animation_player.seek(animation_time * 0.8, true)
	
	main_container.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_INHERITED
	
	page = MainMenuPage.MAIN
	set_transitioning()
	
	SaveDataManager.save_data()
	
func _on_social_media_back_button_pressed() -> void:
	if (transitioning):
		return
		
	social_media_animation_player.play_backwards("open_social_media")
	social_media_animation_player.seek(animation_time * 0.8, true)
	
	main_container.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_INHERITED
	
	page = MainMenuPage.MAIN
	set_transitioning()
	
	SaveDataManager.save_data()
	
#Trigged by OrdersAnimationPlayer
func set_orders_scene_visibility(new_visible: bool) -> void:
	orders_scene.visible = new_visible
	
#Trigged by VoicemailsAnimationPlayer
func set_voicemails_scene_visibility(new_visible: bool) -> void:
	voicemails_scene.visible = new_visible
	
#Trigged by SettingsAnimationPlayer
func set_settings_scene_visibility(new_visible: bool) -> void:
	settings_scene.visible = new_visible
	
#Trigged by SocialMediaAnimationPlayer
func set_social_media_scene_visibility(new_visible: bool) -> void:
	social_media_scene.visible = new_visible

func set_transitioning() -> void:
	transitioning = true
	await get_tree().create_timer(animation_time).timeout 
	transitioning = false
