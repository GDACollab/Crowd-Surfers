extends Control

@export var pause_screen_scene: PackedScene

func _ready() -> void:
	visible = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("open_pause_menu"):
		if get_child_count() == 0:
			visible = true
			var pause_screen: Node = pause_screen_scene.instantiate()
			add_child(pause_screen)
			get_tree().paused = true
		elif get_child(0).transitioning != true:
			visible = false
			get_tree().paused = false
			get_child(0).queue_free()
