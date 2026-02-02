class_name stomp_ability extends Ability

@export var stomp_speed: float

# Player's momentum in the xz-plane just before activating stomp
var player_original_momentum: Vector2 = Vector2(0, 0)

func Use(player: CharacterBody3D) -> void:
	player_original_momentum = Vector2(player.velocity.x, player.velocity.z)
	player.velocity = Vector3(0,stomp_speed,0)
	
func Exit(_player: CharacterBody3D) -> void:
	pass
