class PlayerAbilityManager extends Ability:
	var abilities: Array[Ability] = [speed_mult.new()]
	
	func Use(player: CharacterBody3D):
		# Call ability at the index of ability key pressed
		
		
		# Check if the ability is of AbilityType.PASSIVE, if so call the Countdown()
		pass
		
	func Exit(player: CharacterBody3D):
		pass
