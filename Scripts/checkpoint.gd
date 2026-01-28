extends Node3D

func _on_area_3d_body_entered(body: Node3D) -> void:
	#print("Checkpoint Activated!!!!!!!!!!!!!")
	if (body.has_method("set_spawnpoint")):
		body.set_spawnpoint(global_position)
