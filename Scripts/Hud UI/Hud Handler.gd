extends Control

## Get references to all components
## I Couldn't figure out signals and did this method lol
@onready var speedometer = $"Hud Container/Speedometer Component"
@onready var timer_Display = $"Hud Container/Timer Component"
@onready var level_progress_Display = $"Hud Container/Level Progress Component"
@onready var hud_container = $"Hud Container/Stars Container"

# Get reference without actually editing the player script
@onready var player: Node = get_parent().get_node("Player")

# track time passed so far
@onready var curr_Time : float = 0.0

@export_category("Stars")
@export var stars: Array[HudStarData]
@export var star_alpha_fade_per_second: float
@export var star_move_distance: float
@export var star_animation_time: float
@export var star_animation_fade_in_multiplier: float = 5.0;
@export var star_animation_time_change_per_second: float = 0.7
@export var hud_star_scene: PackedScene

var star_images: Array[TextureRect]
var star_base_modulate: Array[float]
var current_animation_time: float
var animation_timer: float = 0
var saved_ramping_cap: float
var player_start_pos: Vector2
var level_end_pos: Vector2
var has_level_end_pos: bool = false

signal change_Lvl_Progress(new_speed: float)

# Assuming that Hud doesn't transfer over to new scenes
# so each level has its own Hud.
# Further development could improve on this hud by making it
# stay on other scenes and reinitialize
func _ready():
	#initialize on scene start up
	saved_ramping_cap = player.base_ramping_cap
	set_max_speed(saved_ramping_cap)
	change_Lvl_Progress.connect(set_Level_Progress)
	set_Level_Progress(0)
	current_animation_time = star_animation_time
	
	# Create stars
	for i in stars.size():
		var star: TextureRect = hud_star_scene.instantiate()
		star.texture = stars[i].texture
		star.position = stars[i].position
		hud_container.add_child(star)
		star_images.append(star)
		star_base_modulate.append(0.0)
	
	#Initialize player start position
	player_start_pos = Vector2(player.position.x, player.position.z)
	
func set_max_speed(new_Speed: float):
	speedometer.set_max_speed(new_Speed)

# Send a call to the script attached to the speedometer component
# that script handles changing the bar value display
func set_player_speed(new_speed: float):
	speedometer.set_speed(new_speed)
	
# send a call to the component with the script attached.
# that script handles changing the display.
func set_Level_Progress(new_Progress: float):
	level_progress_Display.set_Progress(new_Progress)
	
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
	
	# This gets the actual speed of the player, not the max speed. No longer used
	#var hypotenuse = pow(pow(player.velocity.x,2) + pow(player.velocity.z,2),.5)
	var max_speed = player.max_speed
	set_player_speed(max_speed)

	##  ------- Handle Stars ---------------
	
	# Slowly ease animation time to account for quick changes to max speed
	var modified_star_animation_time = (0.5 * star_animation_time) + (0.5 * star_animation_time) * (1 - (max_speed / saved_ramping_cap))
	if (current_animation_time < modified_star_animation_time):
		current_animation_time += star_animation_time_change_per_second * delta
		current_animation_time = min(current_animation_time, modified_star_animation_time)
	else:
		current_animation_time -= star_animation_time_change_per_second * delta
		current_animation_time = max(current_animation_time, modified_star_animation_time)
		
	# Timer progresses slower for a longer animation time and faster for a slower animation time
	animation_timer += delta / current_animation_time;
		
	var index: int = 0
	for star in star_images:
		if (stars[index].speed_percent_to_show < max_speed):
			if (star_base_modulate[index] < 1):
				star_base_modulate[index] += star_alpha_fade_per_second * delta
		elif (star.modulate.a > 0):
				star_base_modulate[index] -= star_alpha_fade_per_second * delta

		var rng = RandomNumberGenerator.new()
		rng.seed = index
		var animation_timer_offset = animation_timer + rng.randf_range(0.0, 1.0)
		# should go from 0 to 1 every current_animation_time seconds
		# (fmod is float modulo, not the sound thing)
		var time_based_multiplier = fmod(animation_timer_offset, 1.0)
		
		star.position = stars[index].position + Vector2(1, -1) * star_move_distance * time_based_multiplier
		
		# Refer to desmos screenshot, but in short, this is zero at both ends, and quickly changes to 1 in the middle
		time_based_multiplier = min(star_animation_fade_in_multiplier * (-abs(time_based_multiplier - 0.5) + 0.5), 1)
		star.modulate.a = star_base_modulate[index] * time_based_multiplier
		
		index += 1
	
	## Calculate and display time
	curr_Time = curr_Time + delta
	set_Time(curr_Time)
		
	## Handle Level Progression
	if(has_level_end_pos):
		var player_dist_to_start = Vector2(player.position.x, player.position.z).distance_to(player_start_pos)
		# Fraction of player distance to total distance, * 100 makes it a percent
		var progress = player_dist_to_start / (level_end_pos.distance_to(player_start_pos)) * 100
		set_Level_Progress(progress)
	# Error message to let level designer know to attach the script
	else:
		print("Error: Level end position not passed to the HUD! Either 1: you didn't attach the \"level.gd\" script to the root node for this scene, or you didn't add a \"LevelEndCollider\" as a child to the root node")
	
	
	
