extends Node3D

@export var level_clear_ui: Control

func _on_area_3d_body_entered(body: Node3D) -> void:
	if (body.name == "Player" && level_clear_ui != null):
		level_clear_ui.visible = true
		level_clear_ui.open_ui()
		get_tree().paused = true

func _input(event: InputEvent) -> void:
	if(Story.debug_mode and event.is_action_pressed("DEBUG_SkipLevel")):
		level_clear_ui.visible = true
		level_clear_ui.open_ui()
		get_tree().paused = true
