extends Node2D

@export var player: Player

# TODO: Logic that handles level_audio playing different music based on the level

func _ready() -> void:
	assert(player)
	var mus_level1 := Audio.create_persistent("mus_level1", "event:/MUS/level_1")
	var amb_city := Audio.create_persistent("amb_city", "event:/SFX/ENV/ambience/city_ambience")
	
	mus_level1.start()
	amb_city.start()

func _process(_delta: float) -> void:
	# interesting player variable names like are you fr
	var speed_range = player.base_ramping_cap
	var horizontal_vel = Vector2(player.velocity.x, player.velocity.z)
	var ratio_of_max_speed = (horizontal_vel.length()) / speed_range
	ratio_of_max_speed = clamp(ratio_of_max_speed, 0, 1)
	# Update FMOD global parameter `player_speed` -- effects city amb and music
	FmodServer.set_global_parameter_by_name("player_speed", ratio_of_max_speed)
