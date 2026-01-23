class_name speed_mult extends Ability

@export var speedMultiplier: float = 3.0
var originalVal: float

func Use(player: CharacterBody3D):
	originalVal = player.acceleration
	player.acceleration *= speedMultiplier

func Exit(player: CharacterBody3D):
	player.acceleration = originalVal
