extends Control

## Get references to all components
## I Couldn't figure out signals and did this method lol
@onready var speed_O_Meter = $"HBoxContainer/SpeedOmeter Component"
@onready var timer_Display = $"HBoxContainer/VBoxContainer/Timer Component"
@onready var level_Display = $"HBoxContainer/VBoxContainer/Level Progress Component"

# Get reference without actually editing the player script
@onready var player = get_parent().get_node("Player")

# track time passed so far
@onready var curr_Time :float = 0.0

# Adds functionality to make the timer count down instead
# of counting up like a stop watch
@export var count_Down: bool = false
@export var time_Limit: float = 30.0


signal change_Lvl_Progress(new_speed: float)

# Assuming that Hud doesn't transfer over to new scenes
# so each level has its own Hud.
# Further development could improve on this hud by making it
# stay on other scenes and reinitialize
func _ready():
	speedometer.speed_changed.connect(_on_speed_changed)
	timerDisplay.timer_changed.connect(_on_time_changed)

func _on_speed_changed(new_speed: float):
	print("Speed updated to:", new_speed)
	
# send a call to the component with the script attached.
# that script handles changing the display.
func set_Level_Progress(new_Progress: float):
	level_Display.set_Progress(new_Progress)
	
func set_Time(new_Time: float):
	timer_Display.set_time(new_Time)

# Place holder function
# Haven't decided how to determine visually what will happen when player loses by time
# so program wise I left a place holder function so easy modiiblity.
# Maybe a signal would be better here?
# gonna wait for some time until a better idea is drawn up or something.
func timer_Done():
	print("timer finished in Hud Handler.gd")
func _process(delta: float) -> void:
	
	## Find player velocity
	# Since player velocity is normalized and reduced if going in two directions
	# we need to find the hypotenuse, aka the real speed.
	
	# First if statement to check if player is
	# only going in a cardinal direction
	# if this is true, then no need to calculate the hypotenuse
	if((player.velocity.x == 0) || (player.velocity.z == 0)):
		set_Player_speed(max(abs(player.velocity.x),abs(player.velocity.z)))
	# if this else statement runs, that means
	# there is a velocity in both X and Z currently
	else:
		# This is just the pythagorthem theorem lol
		# ty eric :thumbs_up:
		var hypotenuse = pow(pow(player.velocity.x,2) + pow(player.velocity.z,2),.5)
		set_Player_speed(hypotenuse)
	
	## Calculate and display time
	curr_Time = curr_Time + delta
	
	## Handle timer display.
	# if true, timer should count down from given time limit
	# should be set in inspector in the scene.
	if (count_Down):
		set_Time(snapped(time_Limit - curr_Time, 0.01))
		if(time_Limit < curr_Time):
			timer_Done()
	else:
		set_Time(snapped(curr_Time, 0.01))
		
	## Handle Level Progression
	# Currently not implemented, as end goals aren't finalized
	# And I would need a demo level to see how to connect endgoal to hud
	
