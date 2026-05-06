extends AnimatedSprite3D

@export var player_path: NodePath
@export var deadzone: float = 0.2

@export var stomp_speed: float = 5.0 
@onready var player: CharacterBody3D = get_node(player_path)

## The horizontal flipping of the player animation before a neutral front/back animation is played
var prev_flip_h := false
## Is the fall animation already playing?
var is_playing_fall := false

func _ready() -> void:
	set_speeds()

func _process(_delta: float) -> void:
	var v := player.velocity
	speed_scale = 0.5 + v.length() / 125.0

func set_speeds():
	#stomp speeds
	sprite_frames.set_animation_speed('stomp_back',stomp_speed)
	sprite_frames.set_animation_speed('stomp_back_side',stomp_speed)
	sprite_frames.set_animation_speed('stomp_front',stomp_speed)
	sprite_frames.set_animation_speed('stomp_front_side',stomp_speed)
	sprite_frames.set_animation_speed('stomp_side',stomp_speed)

## Handles special logic for playing the skate animation or the idle
func skate_animation():
	var v := player.velocity
	if abs(v.x) < deadzone and abs(v.z) < deadzone:
		speed_scale = 1.0
		# This is for jumping in-place. Slip will face the same direction they did before jumping
		# Neutral animations shut off the flipping, so we need to use whatever the flip was before
		# the animation
		flip_h = prev_flip_h
		play("skate_idle")
	else:
		play_animation("skate")

func play_animation(action: String) -> void:
	is_playing_fall = action == "fall"
	var v := player.velocity
	# Only flip sprite if slip is moving right
	if abs(v.x) > deadzone:
		prev_flip_h = flip_h
		flip_h = v.x < 0
	else:
		flip_h = false
	play(action + get_animation_dir(v.x, v.z))

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
