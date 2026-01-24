extends Area3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	#Player must be a different layer for this to work. In this case, we need the player to be layer 2.
	if body.collision_layer == 2:
		call_deferred("restart_scene")
		

func restart_scene() -> void:
	get_tree().reload_current_scene()
