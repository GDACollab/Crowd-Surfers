extends Node3D

#Call crowd function in player
func _on_crowd_area_area_entered(player : CharacterBody3D) -> void:
	player.on_crowd_entered()
