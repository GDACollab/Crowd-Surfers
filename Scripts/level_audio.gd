extends FmodEventEmitter3D

@export var player: CharacterBody3D = null

var player_max_speed: float;

func _ready() -> void:
	assert(player)
	player_max_speed = player.base_ramping_cap
	assert(player_max_speed)

func _process(_delta: float) -> void:
	# Update FMOD parameter `player_speed`
	var speed_ratio = player.velocity.length() / player_max_speed
	speed_ratio = clamp(speed_ratio, 0, 1)
	self.set_parameter("player_speed", speed_ratio)
