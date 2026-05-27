extends Node2D

@export var player: Player
@export var music_path: String
@export var ambience_path: String

# TODO: Logic that handles level_audio playing different music based on the level

func _ready() -> void:
	assert(player and music_path and ambience_path)
	var mus_level := Audio.create_persistent("mus_level", music_path, true)
	var amb_city := Audio.create_persistent("amb_city", ambience_path, true)
	var skating_loop := Audio.create_persistent("skating_loop", "event:/SFX/P/skate_loop", true)
	
	mus_level.start()
	amb_city.start()
	skating_loop.start()

func _process(_delta: float) -> void:
	# interesting player variable names like are you fr
	var speed_range = player.base_ramping_cap
	var horizontal_vel = Vector2(player.velocity.x, player.velocity.z)
	var vertical_vel = Vector2(player.velocity.y, 1.)
	var ratio_of_max_speed = (max(horizontal_vel.length(), vertical_vel.length())) / speed_range
	ratio_of_max_speed = clamp(ratio_of_max_speed, 0, 1)
	# Update FMOD global parameter `player_speed` -- effects city amb and music
	FmodServer.set_global_parameter_by_name("player_speed", ratio_of_max_speed)
