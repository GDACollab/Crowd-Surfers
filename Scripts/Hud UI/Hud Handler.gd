extends Control

## Get references to all components
## I Couldn't figure out signals and did this method lol
@onready var speedometer = $"HudContainer/Speedometer Component"
@onready var timer_Display = $"HudContainer/Timer Component"
@onready var level_Display = $"HudContainer/Level Progress Component"

# Get reference without actually editing the player script
@onready var player: Node = get_parent().get_node("Player")

# track time passed so far
@onready var curr_Time : float = 0.0

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
	speedometer.set_Max_Speed(new_Speed)

# Send a call to the script attached to the speed_O_Meter component
# that script handles changing the bar value display
func set_Player_speed(new_Speed: float):
	speedometer.set_speed(new_Speed)
	
# send a call to the component with the script attached.
# that script handles changing the display.
func set_Level_Progress(new_Progress: float):
	level_Display.set_Progress(new_Progress)
	
func set_Time(new_Time: float):
	timer_Display.set_timer_text(get_Formatted_Timer_Text(new_Time, true))
	
func get_Formatted_Timer_Text(time: float, sprites: bool = false) -> String:
	var rounded_time: float = snapped(time, 0.01)
	var seconds: String = str(int(rounded_time) % 60)
	var minutes: int = int(rounded_time / 60)
	if (seconds.length() == 1 && minutes > 0):
		seconds = "0" + seconds

	var centi_seconds: String = str(int((rounded_time - int(rounded_time)) * 100))
	if (centi_seconds.length() == 1):
		centi_seconds += "0"
		
	var formatted_time: String = seconds + ":" + str(centi_seconds)
	
	if (minutes != 0):
		formatted_time = str(minutes) + ":" + formatted_time;
		
	if (sprites):
		var sprite_formatted_time: String = ""
		for character in formatted_time:
			if (character == ':'):
				sprite_formatted_time += "[img]res://Assets/Art/UI/HUD/TimerNumbers/colon.png[/img]"
			else:
				sprite_formatted_time += "[img]res://Assets/Art/UI/HUD/TimerNumbers/" + character + ".png[/img]"
		formatted_time = sprite_formatted_time;
		
	return formatted_time

func _process(delta: float) -> void:
	
	## Find player velocity
	# Since player velocity is normalized and reduced if going in two directions
	# we need to find the hypotenuse, aka the real speed.
	
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
	
