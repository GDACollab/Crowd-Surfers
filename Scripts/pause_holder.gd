extends Control

@export var pause_screen_scene: PackedScene

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("open_pause_menu") and get_child_count() == 0:
		var pause_screen: Node = pause_screen_scene.instantiate()
		add_child(pause_screen)
		Engine.time_scale = 0.0
