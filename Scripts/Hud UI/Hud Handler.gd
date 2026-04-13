extends Control

## Get references to all components
## I Couldn't figure out signals and did this method lol
@onready var speedometer = $"Hud Container/Speedometer Component"
@onready var timer_Display = $"Hud Container/Timer Component"
@onready var level_Display = $"Hud Container/Level Progress Component"
@onready var hud_container = $"Hud Container/Stars Container"

# Get reference without actually editing the player script
@onready var player: Node = get_parent().get_node("Player")

# track time passed so far
@onready var curr_Time : float = 0.0

@export_category("Stars")
@export var stars: Array[HudStarData]
@export var star_scale: float
@export var star_alpha_fade_per_second: float

var starImages: Array[TextureRect]

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
	
	# Create stars
	for i in stars.size():
		var star: TextureRect = TextureRect.new()
		star.texture = stars[i].texture
		star.position = stars[i].position
		star.scale = Vector2(star_scale, star_scale)
		hud_container.add_child(star)
		starImages.append(star)
	
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
	timer_Display.set_timer_text(get_Formatted_Timer_Text(new_Time, false, true), get_Formatted_Timer_Text(new_Time, true, true))
	
func get_Formatted_Timer_Text(time: float, centiseconds: bool = false, sprites: bool = false) -> String:
	var rounded_time: float = snapped(time, 0.01)
	var seconds: String = str(int(rounded_time) % 60)
	if (seconds.length() == 1):
		seconds = "0" + seconds
		
	var minutes: String = str(int(rounded_time / 60))
	if (minutes.length() == 1):
		minutes = "0" + minutes
		
	var centi_seconds: String = str(int((rounded_time - int(rounded_time)) * 100))
	if (centi_seconds.length() == 1):
		centi_seconds += "0"
		
	var formatted_time: String
	if (centiseconds):
		formatted_time = "." + str(centi_seconds)
	else:
		formatted_time = minutes + ":" + seconds
		
	if (sprites):
		var sprite_formatted_time: String = ""
		for character in formatted_time:
			if (character == ':'):
				sprite_formatted_time += "[img]res://Assets/Art/UI/HUD/TimerNumbers/colon.png[/img]"
			elif (character == '.'):
				sprite_formatted_time += "[img]res://Assets/Art/UI/HUD/TimerNumbers/period.png[/img]" 
			else:
				sprite_formatted_time += "[img]res://Assets/Art/UI/HUD/TimerNumbers/" + character + ".png[/img]"
		formatted_time = sprite_formatted_time
		
	return formatted_time

func _process(delta: float) -> void:
	
	## Find player velocity
	# Since player velocity is normalized and reduced if going in two directions
	# we need to find the hypotenuse, aka the real speed.
	
	# This is just the pythagorthem theorem lol
	# ty eric :thumbs_up:
	var hypotenuse = pow(pow(player.velocity.x,2) + pow(player.velocity.z,2),.5)
	set_Player_speed(hypotenuse)
	
	## Handle Stars
	var index: int = 0
	for star in starImages:
		if (stars[index].speed_percent_to_show < hypotenuse):
			if (star.modulate.a < 1):
				star.modulate.a += star_alpha_fade_per_second * delta
		elif (star.modulate.a > 0):
				star.modulate.a -= star_alpha_fade_per_second * delta
		index += 1
	
	## Calculate and display time
	curr_Time = curr_Time + delta
	set_Time(curr_Time)
		
	## Handle Level Progression
	# Currently not implemented, as end goals aren't finalized
	# And I would need a demo level to see how to connect endgoal to hud
	
	
	
