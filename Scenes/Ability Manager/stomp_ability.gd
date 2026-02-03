class_name stomp_ability extends Ability

@export var stomp_speed: float

var dash_activated_near_ground: bool = false

# Player's momentum in the xz-plane just before activating stomp
var player_original_momentum: Vector2 = Vector2(0, 0)

func Use(player: CharacterBody3D) -> void:
	player_original_momentum = Vector2(player.velocity.x, player.velocity.z)
	player.velocity = Vector3(0,stomp_speed,0)
	
func Exit(player: CharacterBody3D) -> void:
	# Restore player's momentum if the dash was activated close enough to the ground
	if dash_activated_near_ground:
		var original_x_speed: float = player_original_momentum.x
		var original_z_speed: float = player_original_momentum.y
		player.velocity = Vector3(original_x_speed, 0.0, original_z_speed)
		# Turn this flag off since stomp is not active
		dash_activated_near_ground = false
