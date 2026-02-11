class_name stomp_ability extends Ability

## Speed at which the player stomps
@export var stomp_speed: float
## Time it takes (in seconds) for the player to come to a stomp before getting sent downwards. CURRENTLY UNIMPLEMENTED
@export var windup_time: float
## Amount to increase speed boost each second the player is falling
@export var speed_boost_incrementor: float

## Speed boost received from the stomp after stomp exits
var player_speed_boost: float = 0.0
## Is stomp active?
var is_active: bool = false

# References
@onready var stomp_sound: FmodEventEmitter3D = $StompSound

func Use(player: CharacterBody3D) -> void:
	# Get just the xz-components of the player's velocity into a vector
	var player_original_momentum := Vector2(player.velocity.x, player.velocity.z)
	# Get the length of this vector and use it as the baseline for the speed boost
	player_speed_boost = player_original_momentum.length()
	# Send the player downwards
	player.velocity = Vector3.DOWN * stomp_speed
	stomp_sound.play()
	is_active = true
	set_process(true)
	
func Exit(_player: CharacterBody3D) -> void:
	player_speed_boost = 0.0
	is_active = false
	
func _ready() -> void:
	set_process(false)

func _process(delta: float) -> void:
	player_speed_boost += speed_boost_incrementor * delta
