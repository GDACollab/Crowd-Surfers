class_name speed_mult extends Ability

@export var speedMultiplier: float = 2.0
var originalVal: float

func Use(player: CharacterBody3D):
	originalVal = player.max_speed
	player.max_speed *= speedMultiplier

func Exit(player: CharacterBody3D):
	player.max_speed = originalVal
