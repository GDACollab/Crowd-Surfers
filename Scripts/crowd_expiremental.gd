extends Node3D

# if in dash state ---> reset cooldown & give speed boost
# if walked into ---> slow player speed by x percent
func _on_area_3d_area_entered(body: Node3D) -> void:
	if (body.name == "Player" && (body.current_state == "Ground Dash" || body.current_state == "Air Dash")):
		print("Crowd Dash")
	elif (body.name == "Player"):
		print("Crowd Walk")
