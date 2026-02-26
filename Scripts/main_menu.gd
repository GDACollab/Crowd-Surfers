extends Control

@onready var orders_animation_player : AnimationPlayer = $OrdersAnimationPlayer

@onready var main_container: Control = $PhoneImage/MainContainer
@onready var orders_scene: Control = $PhoneImage/OrdersScene

func _ready() -> void:
	orders_scene.visible = false

func _on_exit_button_pressed() -> void:
	SceneFadeTransition.transition_to_scene(load("res://Scenes/UI Menus/TitleScreen.tscn"))

func _on_orders_button_pressed() -> void:
	orders_animation_player.play("open_orders")
	orders_scene.visible = true
	
#Signalled by back button inside orders scene
func _on_back_button_pressed() -> void:
	orders_animation_player.play_backwards("open_orders")
	
#Trigged by OrdersAnimationPlayer
func set_orders_scene_visibility(new_visible: bool) -> void:
	orders_scene.visible = new_visible
