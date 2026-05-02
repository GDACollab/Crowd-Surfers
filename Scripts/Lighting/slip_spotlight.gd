extends Node3D
class_name SlipSpotlight

@export var slip : Player
@export var follow_speed := 5.0
var follow_pos : Vector3

func _physics_process(delta: float) -> void:
	follow_pos = Vector3(slip.global_position.x, global_position.y, slip.global_position.z)
	global_position = global_position.lerp(follow_pos, delta * follow_speed)
