class_name glide_ability extends Ability

# duration determines when the slowdown occurs, default currently is 1.0

# gravity is simply how much gravity is applied while gliding, default currently 0.0
@export var gravityMultiplier: float = 0.0
# how fast you lose speed, default currenlty is 0.1
@export var speedDropoff: float = 0.1
# how fast expontentially speed decrease should be, default is currently recommended as 1.0, it's very sensitive
# incase of adjustment, recommended change around the 1.00000 - 1.00100 
@export var speedExpoRate: float = 1.0
# the speed needed to be at before the glide doesn't work, default is currently 0.0
@export var dropEnd: float = 0.0
# note: when the drop in speed occurs, is based on duration (important!!!)
var originalVal: float
var originalCurrSpeed: float
var originalDropoff: float
var myPlayer: CharacterBody3D
var activated: bool = false
var available: bool = true

# initalizer, which makes sure to set _process off
func _ready():
	set_process(false)
	
# Processes which slowly decreases the speed of the player incremetally
func _process(delta: float) -> void: 
	# internal clock to better control speed drop off rate
	if (activated and (myPlayer.base_max_speed > dropEnd and myPlayer.velocity.length() > dropEnd)):
		myPlayer.base_max_speed -= speedDropoff * speedExpoRate
		speedDropoff *= speedExpoRate
		if (myPlayer.base_max_speed <= 0): myPlayer.base_max_speed = 0
		myPlayer.velocity.x = move_toward(myPlayer.velocity.x, 0 * myPlayer.base_max_speed, myPlayer.acceleration * delta)
		myPlayer.velocity.z = move_toward(myPlayer.velocity.z, 0 * myPlayer.base_max_speed, myPlayer.acceleration * delta)
	elif (activated): 
		Exit(myPlayer)
		# Resets use of ability when player touches the floor
	if (myPlayer.is_on_floor()) :
		available = true
		myPlayer.base_max_speed = originalCurrSpeed
		speedDropoff = originalDropoff
		set_process(false)
	

# initial call to start the glide
# saves prior attributes to reset later
func Use(player: CharacterBody3D):
	if (!activated and !player.is_on_floor() and available):
		originalVal = player.gravity
		originalCurrSpeed = player.base_max_speed
		originalDropoff = speedDropoff
		
		player.gravity *= gravityMultiplier
		player.velocity.y = 0
		
		myPlayer = player
		activated = true
		available = false
		$Timer.start(duration)
	# Checks if the player calls mid-air to cancel flight, won't allow them 
	# to call it until timer duration is finished.
	elif (!available):
		$Timer.stop()
		set_process(true)
		
		Exit(myPlayer)
		

# exit will start process to exit, best to call to end, but warning, timer still exists and process
func Exit(player: CharacterBody3D):
	player.gravity = originalVal
	activated = false

# timeout, used to start the process of checking and applying glide consistently
func _on_timer_timeout() -> void:
	# starts the checking process
	set_process(true)
