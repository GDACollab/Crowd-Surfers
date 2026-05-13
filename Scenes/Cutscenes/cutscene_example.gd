extends Node

func _ready() -> void:
	play_anim("Cutscene_Test")
func pause_for_input():
	$AnimationPlayer.pause()

func play_anim(animation_name):
	$AnimationPlayer.play("Cutscene_Test")

func stop_anim():
	$AnimationPlayer.stop()
