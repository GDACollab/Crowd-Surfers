extends Node2D

@export var player: Player

@onready var music: FmodEventEmitter2D = $Music
@onready var city_ambience: FmodEventEmitter2D = $CityAmbience

func _ready() -> void:
	assert(player)
	music.play()
	city_ambience.play()
	

func _process(_delta: float) -> void:
	# interesting player variable names like are you fr
	var speed_range = player.base_ramping_cap
	var ratio_of_max_speed = (player.velocity.length()) / speed_range
	ratio_of_max_speed = clamp(ratio_of_max_speed, 0, 1)
	# Update FMOD global parameter `player_speed` -- effects city amb and music
	FmodServer.set_global_parameter_by_name("player_speed", ratio_of_max_speed)
