class_name grav_mult extends Ability

@export var gravityMultiplier: float = 0.0
# how fast you lose speed
@export var speedDropoff: float = 0.2
# the speed needed to be at before the glide doesn't work
@export var dropEnd: float = 0.0
# note: when the drop in speed occurs, is based on duration
var originalVal: float
var originalCurrSpeed: float
var myPlayer: CharacterBody3D
var activated: bool = false
var available: bool = true

# TEMPLATE FOR PASSIVE ABILITIES! (ie abilities that are activated for a small portion of time)
# Reference and modify as you'd like :)d 

# ISSUE (1/25): If multiple abilities access, save then change the same value, then revert it later,
# They can overwrite it to the wrong value!
# when a base value and a seperate current value are added:
# Make sure to save the base value and modify the current value, then revert it later

# initalizer, which makes sure to set _process off
func _ready():
	set_process(false)
	
# Processes which slowly decreases the speed of the player incremetally
func _process(delta: float) -> void: 
	# internal clock to better control speed drop off rate
	
	
	if (activated and myPlayer.base_max_speed > dropEnd):
		myPlayer.base_max_speed -= speedDropoff
			
	elif (activated): 
		Exit(myPlayer)
		# Resets use of ability when player touches the floor
	if (myPlayer.is_on_floor()) :
		available = true
		myPlayer.base_max_speed = originalCurrSpeed
		set_process(false)
	


func Use(player: CharacterBody3D):
	if (!activated and !player.is_on_floor() and available):
		originalVal = player.gravity
		originalCurrSpeed = player.base_max_speed
		
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
		

func Exit(player: CharacterBody3D):
	player.gravity = originalVal
	activated = false

func _on_timer_timeout() -> void:
	# starts the checking process
	set_process(true)
