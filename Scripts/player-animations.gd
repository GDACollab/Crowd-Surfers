extends AnimatedSprite3D

@export var player_path: NodePath
@export var deadzone: float = 0.2

@export var stomp_speed: float = 5.0 
@export var glide_animation_speed: float = 10.0
@onready var player: CharacterBody3D = get_node(player_path)

# Track the last animation played before changing so we can handle looping animations correctly
func _on_animation_changed() -> void:
	last_animation = current_animation

func _on_animation_finished() -> void:
	# Effectively, state machine in null state until a new animation is played
	if not current_animation == "crash":
		current_animation = ""

## The horizontal flipping of the player animation before a neutral front/back animation is played
var prev_flip_h := false
## A string identifying the currently playing animation
var current_animation: String = ""
## A string identifying the last animation played
var last_animation: String = ""
## The direction the player crashed into the wall
var crash_dir: Vector3

func _ready() -> void:
	set_speeds()

func _process(_delta: float) -> void:
	var v := player.velocity
	speed_scale = 0.5 + v.length() / 125.0
	# Glide and Stomp should have constant animation speeds
	if current_animation == "glide" or current_animation == "stomp" or current_animation == "glide_exit":
		speed_scale = 1.0
	# Flip Slip's sprite if they are moving right
	if v.x != 0.0:
		prev_flip_h = flip_h
		flip_h = v.x < 0.0
	if current_animation == "crash" or current_animation == "crash_exit":
		flip_h = crash_dir.x < 0.0

func set_speeds():
	sprite_frames.set_animation_speed('stomp_back',stomp_speed)
	sprite_frames.set_animation_speed('stomp_back_side',stomp_speed)
	sprite_frames.set_animation_speed('stomp_front',stomp_speed)
	sprite_frames.set_animation_speed('stomp_front_side',stomp_speed)
	sprite_frames.set_animation_speed('stomp_side',stomp_speed)
	
	sprite_frames.set_animation_speed('glide_back',glide_animation_speed)
	sprite_frames.set_animation_speed('glide_back_side',glide_animation_speed)
	sprite_frames.set_animation_speed('glide_front',glide_animation_speed)
	sprite_frames.set_animation_speed('glide_front_side',glide_animation_speed)
	sprite_frames.set_animation_speed('glide_side',glide_animation_speed)
	
	sprite_frames.set_animation_speed('glide_exit_back',glide_animation_speed)
	sprite_frames.set_animation_speed('glide_exit_back_side',glide_animation_speed)
	sprite_frames.set_animation_speed('glide_exit_front',glide_animation_speed)
	sprite_frames.set_animation_speed('glide_exit_front_side',glide_animation_speed)
	sprite_frames.set_animation_speed('glide_exit_side',glide_animation_speed)

## Handles special logic for playing the idle animation
func play_idle_animation():
	var v := player.velocity
	if abs(v.x) < deadzone and abs(v.z) < deadzone:
		speed_scale = 1.0
		# This is for jumping in-place. Slip will face the same direction they did before jumping
		# Neutral animations shut off the flipping, so we need to use whatever the flip was before
		# the animation
		const idle_anim_name := "idle"
		flip_h = prev_flip_h
		current_animation = idle_anim_name
		play(idle_anim_name)

## Takes the name of an action and selects a specific animation to play
func play_animation(action: String, continue_animation: bool = false, custom_speed: float = 1.0) -> void:
	var v := player.velocity
	
	# Unflip Slip if they are moving (neutral animation: front or back)
	if v.x == 0.0:
		flip_h = false
	current_animation = action
	
	var current_frame := 0
	var current_progress := 0.0
	# Save progress if we are continuing an animation type
	if continue_animation and last_animation == current_animation:
		current_frame = frame
		current_progress = frame_progress
	var dir := v
	if action == "crash" or action == "crash_exit":
		dir = crash_dir
		
	play(action + get_animation_dir(dir.x, dir.z), custom_speed)
	set_frame_and_progress(current_frame, current_progress)

## Returns a string to be appended to a base action name to help find the specific animation to play
func get_animation_dir(x_dir: float, z_dir: float) -> String:
	if abs(x_dir) > deadzone and abs(z_dir) > deadzone:
		if z_dir >= 0:
			return "_front_side"
		else:
			return "_back_side"
	elif abs(x_dir) > deadzone:
		return "_side"
	else:
		if z_dir >= 0:
			return "_front"
		else:
			return "_back"
