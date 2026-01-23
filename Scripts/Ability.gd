@abstract 
class_name Ability extends Node

enum AbilityType{ACTIVE, PASSIVE}
	
@export var abilityType: AbilityType
@export var duration: float
	
# Changes a stat value on the player
@abstract func Use(playerController)
	
# Undoes stat change from Use()
@abstract func Exit(playerController)
	
# Trigger a timer starting at duration if PASSIVE ability is used
func Countdown():
	$CountdownTimer.start(duration)
	

func _on_countdown_timer_timeout() -> void:
	# Replace with call to the Exit() function
	pass
	
