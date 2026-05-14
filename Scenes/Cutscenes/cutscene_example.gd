extends Node

func _ready() -> void:
	$AnimationPlayer.play("Cutscene_Test")

func pause_for_input():
	$AnimationPlayer.pause()

func _input(event):
	# Listen for a left mouse click
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# If the animation is currently paused, resume it
		if not $AnimationPlayer.is_playing():
			$AnimationPlayer.play()
