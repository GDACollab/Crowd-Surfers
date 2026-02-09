extends Ability

## The distance the player will move when using the ability.
@export var dash_length : float = 70.0

## The temporary speed boost that the player gains on ability use. This boost is relative to current player speed.
@export var dash_speed : float = 1.1

## The cooldown (in seconds) where this ability becomes unusable until cooldown is complete. Different than the duration.
@export var dash_cooldown : float = 1.2

@export var can_dash_midair : bool = true

var original_val : float
var my_player: CharacterBody3D
var activated: bool = false

func Use(player: CharacterBody3D):
	if(!activated):
		my_player = player
		
		# Get the players most recent directional input and their velocity
		var newest_dir_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		var stored_momentum = player.velocity.length()

		var direction := (player.transform.basis * Vector3(newest_dir_input.x, 0, newest_dir_input.y)).normalized()
		
		# Change velocity from current direction and have it move towards the directional input.
		if !direction:
			print("New Input recorded as ZERO.")
		
		# If you dash into a glide/airborne, then momentum should not be removed.
		#if not player.is_on_floor():
			
			if can_dash_midair:
				#print("Dash in AIR")
				player.velocity.x = move_toward(0.0, direction.x * stored_momentum, dash_length)
				player.velocity.z = move_toward(0.0, direction.z * stored_momentum, dash_length)
			else:
				print("Midair dash disabled.")
		#else:
			#print("Dash on GROUND")
			#player.velocity.x = move_toward(stored_momentum, newest_dir_input.x, dash_length)
			#player.velocity.z = move_toward(stored_momentum, newest_dir_input.z, dash_length)
				
			
		# Burst of speed is relative to your current speed
		original_val = max(player.base_max_speed,2.5);
		player.current_max_speed = original_val  * dash_speed + stored_momentum
		#Set velocity values to max speed in the inputed direction
		player.velocity.x = move_toward(player.velocity.x, player.current_max_speed*direction.x, dash_length)
		player.velocity.z = move_toward(player.velocity.z, player.current_max_speed*direction.z, dash_length)
		
		# Start timers, implemented with seperate timers in case cooldown and duration of the speed boost
		# are intended to last at different times, (i.e. CD @ 3 seconds, Duration @ 2.5 seconds)
		$Duration.start(duration)
		$Cooldown.start(dash_cooldown)
		#activated = true
	
func Exit(player: CharacterBody3D):
	player.current_max_speed = original_val
	pass

func _on_cooldown_timeout() -> void:
	activated = false

func _on_duration_timeout() -> void:
	Exit(my_player)
