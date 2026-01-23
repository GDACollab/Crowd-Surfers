@abstract 
class_name Ability extends Node

enum AbilityType {ACTIVE, PASSIVE}

# Don't know how to really use the @export values, setting default for placeholder
@export var abilityType: AbilityType = AbilityType.PASSIVE
@export var duration: float = 1.0
	
# Changes a stat value on the player
@abstract func Use(playerController)
	
# Undoes stat change from Use()
@abstract func Exit(playerController)
	
# Trigger a timer starting at duration if PASSIVE ability is used
func Countdown():
	# Check if the ability is of AbilityType.PASSIVE, if so call the Countdown()
	if abilityType == AbilityType.PASSIVE:
		pass

func _on_timer_Timeout(player: CharacterBody3D):
	Exit(player)
