extends AnimatedSprite3D

@export var player_path: NodePath
@export var deadzone: float = 0.2

@onready var player: CharacterBody3D = get_node(player_path)

func _process(delta: float) -> void:
	var v := player.velocity
	var x := v.x
	var z := v.z

	if abs(x) < deadzone and abs(z) < deadzone:
		speed_scale = 1.0
		play("skate_idle")
		return

	if x > 0:
		flip_h = false
	if x < 0:
		flip_h = true

	speed_scale = 0.5 + v.length()/125

	if abs(x) > deadzone and abs(z) > deadzone:
		if z > 0:
			play("skate_down_right")
		else:
			play("skate_up_right")
	elif abs(x) > deadzone:
		play("skate_right")
	else:
		if z > 0:
			play("skate_down")
		else:
			play("skate_up")
