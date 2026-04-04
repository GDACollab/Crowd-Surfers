extends Node3D

@export var wind_speed: float = 1000.0

func _on_area_3d_body_entered(body: Node3D) -> void:
	print(body.name)
	if (body.name == "Player"):
		body.velocity.y = wind_speed
		print('wind')
