class_name dash_ability extends Ability

## Affects the distance the player will move when this ability is used.
@export var dash_length : float = 40.0
## The temporary speed boost that the player gains on ability use.
@export var dash_speed : float = 1.2
## The cooldown (in seconds) where this ability becomes unusable until cooldown is complete. Different than the duration.
@export var dash_cooldown : float = 1.3
## A toggle whether the player is allowed to use the dash ability when in the air.
@export var can_dash_midair : bool = true

## What was the players current_max_speed
var original_val : float
var my_player: CharacterBody3D
## Is the dash off cooldown and ready to be used?
var is_ready: bool = true
## Speed boost gained from the stomp
var speed_boost_from_stomp: float

func Use(player: CharacterBody3D):
	if(is_ready):
		my_player = player
		# Get the players most recent directional input and their velocity
		var newest_dir_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		# Store the player's speed from before the dash and add in the boost from stomp
		var stored_momentum = player.velocity.length() + speed_boost_from_stomp
		var direction := (player.transform.basis * Vector3(newest_dir_input.x, 0, newest_dir_input.y)).normalized()
		# Change velocity from current direction and have it move towards the directional input.
		if not direction:
			print("New Input recorded as ZERO.")
			# without this just sets velocity to ZERO if player didn't have input
			return

		# Burst of speed is relative to your current speed
		original_val = player.base_max_speed
		player.current_max_speed = player.base_max_speed * dash_speed + stored_momentum
		
		if not can_dash_midair and not player.is_on_floor() :
			print("Midair dash disabled")
		# Apply speed boost from stomp
		elif speed_boost_from_stomp > 0.0:
			player.velocity = direction * speed_boost_from_stomp
		else:
			player.velocity.x = move_toward(player.velocity.x, player.current_max_speed * direction.x, dash_length)
			player.velocity.z = move_toward(player.velocity.z, player.current_max_speed * direction.z, dash_length)
		
		# Start timers, implemented with seperate timers in case cooldown and duration of the speed boost
		# are intended to last at different times, (i.e. CD @ 3 seconds, Duration @ 2.5 seconds)
		$Duration.start(duration)
		$Cooldown.start(dash_cooldown)
		is_ready = false
	
func Exit(player: CharacterBody3D):
	player.current_max_speed = original_val
	pass

func _on_cooldown_timeout() -> void:
	is_ready = true

func _on_duration_timeout() -> void:
	Exit(my_player)
