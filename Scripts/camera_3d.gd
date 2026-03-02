extends Camera3D

@export var player_path: NodePath
@export var follow_speed: float = 0.5

@onready var player: CharacterBody3D = get_node(player_path)

@export var offset: Vector3 = Vector3(0, 10000, 10000)

var lead_smoothed: Vector3 = Vector3.ZERO

func _process(delta: float) -> void:
	var v: Vector3 = player.velocity
	var lead_target: Vector3 = v.normalized() * sqrt(v.length() + 1.0) * 3.0
	lead_smoothed = lead_smoothed.lerp(
		lead_target,
		1.0 - exp(-follow_speed * delta)
	)
	global_position = player.global_position + offset + lead_smoothed
