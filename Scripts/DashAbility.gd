extends Ability

## The distance the player will move when using the ability.
@export var dash_length : float = 5.0

## The temporary speed boost that the player gains on ability use. This boost is relative to current player speed.
@export var dash_speed : float = 1.2

## The cooldown (in seconds) where this ability becomes unusable until cooldown is complete.
@export var dash_cooldown : float = 2.0

var original_val : float
var my_player: CharacterBody3D
var activated: bool = false

func Use(player: CharacterBody3D):
	if(!activated):
		my_player = player
		
		# Get the players most recent directional input and their velocity
		var newest_dir_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		var stored_momentum = player.velocity.length()

		var direction := (player.transform.basis * Vector3(newest_dir_input.x, 0, newest_dir_input.y))
		
		# If you dash into a glide/airborne, then momentum should not be removed.
		# Dashes should allow instant redirection, all other momentum is routed to point at directional input.
		# Change velocity from current direction and have it move towards the directional input.
		if direction:
			player.velocity.x = move_toward(0.0, direction.x * stored_momentum, dash_length)
			player.velocity.z = move_toward(0.0, direction.z * stored_momentum, dash_length)
		else:
			print("Input recorded as ZERO")
			
		if not player.is_on_floor():
			print("Dash in AIR")
		else:
			print("Dash on GROUND")
		
		
		# Burst of speed is relative to your current speed
		original_val = player.base_max_speed
		player.current_max_speed = player.base_max_speed * dash_speed + stored_momentum
		
		# Start timers
		$Duration.start(duration)
		$Cooldown.start(dash_cooldown)
		activated = true
	
func Exit(player: CharacterBody3D):
	player.current_max_speed = original_val
	pass

func _on_cooldown_timeout() -> void:
	activated = false

func _on_duration_timeout() -> void:
	Exit(my_player)
