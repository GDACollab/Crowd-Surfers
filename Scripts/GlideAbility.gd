class_name grav_mult extends Ability

@export var gravityMultiplier: float = 0.0
var originalVal: float
var myPlayer: CharacterBody3D
var activated: bool = false
var available: bool = true

# TEMPLATE FOR PASSIVE ABILITIES! (ie abilities that are activated for a small portion of time)
# Reference and modify as you'd like :)d 

# ISSUE (1/25): If multiple abilities access, save then change the same value, then revert it later,
# They can overwrite it to the wrong value!
# when a base value and a seperate current value are added:
# Make sure to save the base value and modify the current value, then revert it later

func Use(player: CharacterBody3D):
	if !activated && !player.is_on_floor() && available:
		originalVal = player.gravity
		
		player.gravity *= gravityMultiplier
		player.velocity.y = 0
		
		myPlayer = player
		$Timer.start(duration)
		activated = true
	# Checks if the player calls mid-air to cancel flight, won't allow them 
	# to call it until timer duration is finished.
	elif activated:
		available = false
		Exit(myPlayer)

func Exit(player: CharacterBody3D):
	player.gravity = originalVal

func _on_timer_timeout() -> void:
	Exit(myPlayer)
	available = true
	activated = false;
	pass # Replace with function body.
