extends Control

## Get references to all components
## I Couldn't figure out signals and did this method lol
@onready var speedometer = $"Hud Container/Speedometer Component"
@onready var timer_Display = $"Hud Container/Timer Component"
@onready var level_progress_Display = $"Level Progress Component"
@onready var hud_container = $"Hud Container"
@onready var stars_container = $"Hud Container/Stars Container"
@onready var hud_background = $"Hud Container/Hud Background"

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
@export var star_rotation_speed: float = 5
@export var star_rotation_magnitude: float = 4

@export_category("Shake")
@export var speed_change_to_shake: float = 50
@export var shake_time: float = 0.5
@export var shake_magnitue: float = 5
@export var num_shakes: int = 15

@export_category("Overspeed")
@export var max_visual_overspeed: float = 150
@export var shader_outline_change_speed: float = 3

@export_category("Act 2 special case")
@export var act_2_otherside: Vector2
@export var act_2: bool = false

var act_2_otherside_reached: bool = false

var star_images: Array[TextureRect]
var star_base_modulate: Array[float]
var current_animation_time: float
var animation_timer: float = 0
var saved_ramping_cap: float

var max_speed_last_frame: float
var shake_timer: float = 0
var total_shakes: int = 0;

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
	
	set_Time(0.0)
	
	current_animation_time = star_animation_time
	
	# Create stars
	for i in stars.size():
		var star: TextureRect = hud_star_scene.instantiate()
		star.texture = stars[i].texture
		star.position = stars[i].position
		stars_container.add_child(star)
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
	timer_Display.set_timer_text(get_Formatted_Timer_Text(new_Time, false), get_Formatted_Timer_Text(new_Time, true))
	
func get_Formatted_Timer_Text(time: float, centiseconds: bool = false) -> String:
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
		
	return formatted_time

func _process(delta: float) -> void:
	## Find player velocity
	# Since player velocity is normalized and reduced if going in two directions
	# we need to find the hypotenuse, aka the real speed.
	
	# This gets the actual speed of the player, not the max speed. No longer used
	#var hypotenuse = pow(pow(player.velocity.x,2) + pow(player.velocity.z,2),.5)
	var max_speed = player.max_speed
	
	# Overspeed shader
	var over_speed: float = max_speed - saved_ramping_cap
	var threshold: float = 1 - 0.25 * (over_speed / max_visual_overspeed)
	var lerp_threshhold: float = lerp(hud_background.material.get_shader_parameter("threshold"), threshold, delta * shader_outline_change_speed)
	hud_background.material.set_shader_parameter("threshold", lerp_threshhold)
	
	max_speed = min(player.max_speed, saved_ramping_cap)
	set_player_speed(max_speed)
	
	if (max_speed > speed_change_to_shake + max_speed_last_frame):
		shake_timer = shake_time
		total_shakes = 0;
	handle_shake(delta)
	
	max_speed_last_frame = max_speed

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
		
		var modified_star_move_distance = (0.5 * star_move_distance) + (0.5 * star_move_distance * (max_speed / saved_ramping_cap))
		star.position = stars[index].position + Vector2(1, -1) * modified_star_move_distance * time_based_multiplier
		
		# Refer to desmos screenshot, but in short, this is zero at both ends, and quickly changes to 1 in the middle
		time_based_multiplier = min(star_animation_fade_in_multiplier * (-abs(time_based_multiplier - 0.5) + 0.5), 1)
		star.modulate.a = star_base_modulate[index] * time_based_multiplier
		
		star.rotation_degrees = star_rotation_magnitude * sin(star_rotation_speed * animation_timer_offset)
		
		index += 1
	
	## Calculate and display time
	if (player_start_pos.distance_to(Vector2(player.position.x, player.position.z)) > 0.01):
		curr_Time = curr_Time + delta
		set_Time(curr_Time)
		
	## Handle Level Progression
	if(has_level_end_pos):
		var progress: float
		var player_dist_to_start: float
		
		if (act_2 == true):
			print("hi")
			if (act_2_otherside_reached == false):
				player_dist_to_start = Vector2(player.position.x, player.position.z).distance_to(player_start_pos)
				progress = player_dist_to_start / (act_2_otherside.distance_to(player_start_pos)) * 50
			else:
				player_dist_to_start = Vector2(player.position.x, player.position.z).distance_to(act_2_otherside)
				progress = 50 + (player_dist_to_start / (level_end_pos.distance_to(act_2_otherside)) * 50)
		
		else:
			player_dist_to_start = Vector2(player.position.x, player.position.z).distance_to(player_start_pos)
			
			# Fraction of player distance to total distance, * 100 makes it a percent
			progress = player_dist_to_start / (level_end_pos.distance_to(player_start_pos)) * 100
			
		if (player.position.x < act_2_otherside.x):
			act_2_otherside_reached = true
			
		
		set_Level_Progress(progress)
	# Error message to let level designer know to attach the script
	else:
		pass
		#print("Error: Level end position not passed to the HUD! Either 1: you didn't attach the \"level.gd\" script to the root node for this scene, or you didn't add a \"LevelEndCollider\" as a child to the root node")
	
	
func handle_shake(delta: float) -> void:
	if (shake_timer > 0):
		if (shake_timer < (shake_time / num_shakes) * (num_shakes - total_shakes)):
			hud_container.position = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized() * shake_magnitue * (shake_timer / shake_time)
			total_shakes += 1
	else:
		hud_container.position = Vector2.ZERO
		
	shake_timer -= delta
