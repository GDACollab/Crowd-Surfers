class_name stomp_ability extends Ability

## Speed at which the player stomps
@export var stomp_speed: float
## Time it takes (in seconds) for the player to come to a stomp before getting sent downwards. CURRENTLY UNIMPLEMENTED
@export var windup_time: float
## Amount to increase speed boost each second the player is falling
@export var speed_boost_factor: float
## Maximum speed boost that can be provided by stomp
@export var max_speed_boost: float

## Speed boost received from the stomp after stomp exits
var player_speed_boost: float = 0.0
## Player speed before using stomp
var player_original_speed: float = 0.0
## Is stomp active?
var is_active: bool = false

# References
@onready var stomp_sound: FmodEventEmitter3D = $StompSound

func Use(player: CharacterBody3D) -> void:
	# Get just the xz-components of the player's velocity into a vector
	var player_original_momentum := Vector2(player.velocity.x, player.velocity.z)
	# Get the length of this vector and use it as the baseline for the speed boost
	player_original_speed = player_original_momentum.length()
	# Send the player downwards
	player.velocity = Vector3.DOWN * stomp_speed
	stomp_sound.play()
	is_active = true
	
func Exit(_player: CharacterBody3D) -> void:
	player_speed_boost = 0.0
	player_original_speed = 0.0
	is_active = false

func _process(delta: float) -> void:
	# If set_process is false, then delta accumulates from the last _process to the next time
	# set_process is true, so I need to keep process on but use a bool
	if not is_active:
		return
	player_speed_boost += speed_boost_factor * delta
	if player_speed_boost > max_speed_boost:
		player_speed_boost = max_speed_boost
	print(player_speed_boost)
