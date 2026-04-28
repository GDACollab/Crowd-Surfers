extends Control

@onready var orders_animation_player : AnimationPlayer = $OrdersAnimationPlayer
@onready var settings_animation_player : AnimationPlayer = $SettingsAnimationPlayer

@onready var main_container: Control = $PhoneImage/MainContainer
@onready var orders_scene: Control = $PhoneImage/OrdersScene
@onready var settings_scene: Control = $PhoneImage/SettingsScene

@export var animation_time: float = 0.3

var transitioning: bool = false

func _ready() -> void:
	orders_scene.visible = false
	settings_scene.visible = false

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
