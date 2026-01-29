extends Ability

@export var dash_speed : float
@export var dash_cooldown : float

var myPlayer: CharacterBody3D
var activated: bool = false

func Use(player: CharacterBody3D):
	if(!activated):
		# Dashes should allow instant redirection, all other momentum is routed to point at directional input
		
		# Burst of speed is relative to your current speed
		
		print("Applying dash.")
		activated = true
		
	# If you dash into a glide/airborne, then momentum should not be removed.
	
func Exit(player: CharacterBody3D):
	
	print ("Removing dash.")


func _on_timer_timeout() -> void:
	Exit(myPlayer)
	activated = false
	pass # Replace with function body.
