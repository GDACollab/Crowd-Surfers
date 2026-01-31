extends Ability

## The distance the player will move when using the ability.
@export var dash_length : float

## The temporary speed boost that the player gains on ability use. This boost is relative to current player speed.
@export var dash_speed : float

## The cooldown (in seconds) where this ability becomes unusable until cooldown is complete.
@export var dash_cooldown : float = 2.0

var original_val : float
var my_player: CharacterBody3D
var activated: bool = false

func Use(player: CharacterBody3D):
	if(!activated):
		# Dashes should allow instant redirection, all other momentum is routed to point at directional input
		
		# Get the players most recent directional input and their velocity
		var newest_dir_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		var stored_momentum = player.get_real_velocity()
		
		print("The most recent Directional Input on player was: ", newest_dir_input)
		print("The players current velocity was: ", stored_momentum)
		
		# If you dash into a glide/airborne, then momentum should not be removed.
		if not player.is_on_floor():
			print("Player is dashing AIR.")
		else:	
			print("Player is dasing GROUND")
		
		# Burst of speed is relative to your current speed
		$Timer.start(dash_cooldown);
		print("Applying dash.")
		activated = true
	
func Exit(player: CharacterBody3D):
	print ("Removing dash.")
	

func _on_timer_timeout() -> void:
	Exit(my_player)
	activated = false
	pass # Replace with function body.
