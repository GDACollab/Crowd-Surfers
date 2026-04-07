extends Node3D

@export var direction: Vector3 = Vector3(0, 1, 0)
@export var speed: float = 500.0

func _on_area_3d_body_entered(body: Node3D) -> void:
	print(body.name)
	if (body.name == "Player"):
		if direction.y != 0:
			if body.can_dash() and Input.is_action_just_pressed("ability_dash") or body.is_dashing():
				body.transition_to(body.States.DASH_AIR)
			else:
				body.transition_to(body.States.AIR)
		body.velocity += direction.normalized() * speed
		print('wind')
