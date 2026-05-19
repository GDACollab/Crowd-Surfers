extends Control

@onready var orders_animation_player : AnimationPlayer = $OrdersAnimationPlayer
@onready var settings_animation_player : AnimationPlayer = $SettingsAnimationPlayer

@onready var main_container: Control = $PhoneImage/MainPhoneMask/MainContainer
@onready var orders_scene: Control = $PhoneImage/MainPhoneMask/OrdersScene
@onready var settings_scene: Control = $PhoneImage/MainPhoneMask/SettingsScene

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

func _ready() -> void:
	orders_scene.visible = false
	settings_scene.visible = false
	
	start_background_position = backgrounds_closer.position
	time = time_between_target_changes
	
	SaveDataManager.save_data()

func _process(delta: float) -> void:
	time += delta
	if (time > time_between_target_changes):
		time = 0
		target_position = start_background_position + Vector2(randf_range(-1 * background_move_radius_x, background_move_radius_x), randf_range(-1 * background_move_radius_y, background_move_radius_y))
		
	velocity = velocity.lerp(target_position - backgrounds_closer.position, delta * background_acceleration_speed)
	if (velocity.length() > background_max_speed):
		velocity = velocity.normalized() * background_max_speed
	backgrounds_closer.position += velocity
	backgrounds_farther.position = start_background_position.lerp(backgrounds_closer.position, far_background_move_percentage)
	
func _on_exit_button_pressed() -> void:
	SceneFadeTransition.transition_to_scene(load("res://Scenes/UI Menus/TitleScreen.tscn"))

func _on_orders_button_pressed() -> void:
	if (transitioning):
		return
	
	orders_animation_player.play("open_orders")
	orders_scene.visible = true
	
	set_transitioning()
	
func _on_settings_button_pressed() -> void:
	if (transitioning):
		return
		
	settings_animation_player.play("open_settings")
	settings_scene.visible = true
	
	set_transitioning()
	
#Signalled by back button inside orders scene
func _on_orders_back_button_pressed() -> void:
	if (transitioning):
		return
		
	orders_animation_player.play_backwards("open_orders")
	orders_animation_player.seek(animation_time * 0.8, true)
	
	set_transitioning()
	
#Signalled by back button inside settings scene
func _on_settings_back_button_pressed() -> void:
	if (transitioning):
		return
		
	settings_animation_player.play_backwards("open_settings")
	settings_animation_player.seek(animation_time * 0.8, true)
	
	set_transitioning()
	
	SaveDataManager.save_data()
	
#Trigged by OrdersAnimationPlayer
func set_orders_scene_visibility(new_visible: bool) -> void:
	orders_scene.visible = new_visible
	
#Trigged by SettingsAnimationPlayer
func set_settings_scene_visibility(new_visible: bool) -> void:
	settings_scene.visible = new_visible

func set_transitioning() -> void:
	transitioning = true
	await get_tree().create_timer(animation_time).timeout 
	transitioning = false
