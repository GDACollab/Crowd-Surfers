extends Camera3D

@export var player_path: NodePath
@export var follow_speed: float = 8   # higher = snappier

@onready var player: Node3D = get_node(player_path)

@export var offset := Vector3(0, 50, 25)

func _process(delta: float) -> void:
	var target := player.global_position + offset
	global_position = global_position.lerp(
		target,
		1.0 - exp(-follow_speed * delta)
	)
