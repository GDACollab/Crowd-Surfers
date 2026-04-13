extends Node3D

@export var direction: Vector3 = Vector3(0, 1, 0)
@export var speed: float = 250.0

func _on_area_3d_body_entered(body: Node3D) -> void:
	print(body.name)
	if (body.name == "Player"):
		if direction.y != 0:
			body.transition_to(body.States.AIR)
		body.velocity += direction.normalized() * speed
		print('wind')
