class_name grav_mult extends Ability

@export var gravityMultiplier: float = 4.0
var originalVal: float
var myPlayer: CharacterBody3D
var activated: bool = false

# TEMPLATE FOR PASSIVE ABILITIES! (ie abilities that are activated for a small portion of time)
# Reference and modify as you'd like :)d 

# ISSUE (1/25): If multiple abilities access, save then change the same value, then revert it later,
# They can overwrite it to the wrong value!
# when a base value and a seperate current value are added:
# Make sure to save the base value and modify the current value, then revert it later

func Use(player: CharacterBody3D):
	if !activated && !player.is_on_floor():
		originalVal = player.gravity
		
		player.gravity /= gravityMultiplier
		
		myPlayer = player
		$Timer.start(duration)
		activated = true

func Exit(player: CharacterBody3D):
	player.gravity = originalVal

func _on_timer_timeout() -> void:
	Exit(myPlayer)
	activated = false;
	pass # Replace with function body.
