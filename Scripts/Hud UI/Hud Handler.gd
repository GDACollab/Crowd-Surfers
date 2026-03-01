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
	#initialize on scene start up
	set_Max_Speed(player.base_ramping_cap)
	change_Lvl_Progress.connect(set_Level_Progress)
	set_Level_Progress(30)
	
func set_Max_Speed(new_Speed: float):
	speed_O_Meter.set_Max_Speed(new_Speed)

# Send a call to the script attached to the speed_O_Meter component
# that script handles changing the bar value display
func set_Player_speed(new_Speed: float):
	speed_O_Meter.set_speed(new_Speed)
	
# send a call to the component with the script attached.
# that script handles changing the display.
func set_Level_Progress(new_Progress: float):
	level_Display.set_Progress(new_Progress)
	
func set_Time(new_Time: float):
	timer_Display.set_timer_text(get_Formatted_Timer_Text(new_Time))
	
func get_Formatted_Timer_Text(time: float) -> String:
	var rounded_time: float = snapped(time, 0.01)
	var seconds: int = int(rounded_time)
	
	var centi_seconds: String = str(int((rounded_time - seconds) * 100))
	if (centi_seconds.length() == 1):
		centi_seconds += "0"
		
	var formatted_time = str(seconds) + ":" + str(centi_seconds)
	return formatted_time

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
	set_Time(curr_Time)
		
	## Handle Level Progression
	# Currently not implemented, as end goals aren't finalized
	# And I would need a demo level to see how to connect endgoal to hud
	
