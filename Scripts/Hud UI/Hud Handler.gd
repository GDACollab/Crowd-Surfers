extends Control

## Get references to all components
## I Couldn't figure out signals and did this method lol
@onready var speed_O_Meter = $"HBoxContainer/SpeedOmeter Component"
@onready var timer_Display = $"HBoxContainer/VBoxContainer/Timer Component"
@onready var level_Display = $"HBoxContainer/VBoxContainer/Level Progress Component"

# Get reference without actually editing the player script
@onready var player = get_parent().get_node("Player")

@onready var time :float = 0


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
	timer_Display.set_time(new_Time)

func _process(delta: float) -> void:
	#print(player.velocity.x)
	#print(player.velocity)
	if(abs(player.velocity.x) >= abs(player.velocity.z)):
		set_Player_speed(abs(player.velocity.x))
	else:
		set_Player_speed(abs(player.velocity.z))
	time = time + delta
	set_Time(snapped(time, 0.01))
	pass
