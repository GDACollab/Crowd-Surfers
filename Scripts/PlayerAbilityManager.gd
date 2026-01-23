extends Node

class PlayerAbilityManager:
	
	func Use(player: CharacterBody3D):
		var ability = speed_mult.new()
		print("Using ability of type: ", ability.abilityType)
		print("Ability has duration of: ", ability.duration)
		ability.Use(player)
		ability.Countdown()
		

var ability_manager = PlayerAbilityManager.new()
@export var abilities: Array[Ability]

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ability_1"):
		ability_manager.Use(get_parent())
