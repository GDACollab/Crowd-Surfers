extends Control

@onready var main_container: VBoxContainer = $MainContainer
@onready var orders_container: ScrollContainer = $OrdersContainer

func _on_exit_button_pressed() -> void:
	SceneFadeTransition.transition_to_scene(load("res://Scenes/UI Menus/TitleScreen.tscn"))

func _on_orders_button_pressed() -> void:
	main_container.visible = false
	orders_container.visible = true
