extends AnimatedSprite3D

@export var player_path: NodePath
@export var deadzone: float = 0.2

@export var stomp_speed: float = 5.0 
@onready var player: CharacterBody3D = get_node(player_path)

var can_play := true
var is_playing_fall := false

func _process(_delta: float) -> void:
	var v := player.velocity
	speed_scale = 0.5 + v.length()/125
	if player.current_state == player.States.GROUND:
	#if can_play:
		skate_animation(v.x, v.z)
	set_speeds()

func set_speeds():
	#stomp speeds
	sprite_frames.set_animation_speed('stomp_back',stomp_speed)
	sprite_frames.set_animation_speed('stomp_back_side',stomp_speed)
	sprite_frames.set_animation_speed('stomp_front',stomp_speed)
	sprite_frames.set_animation_speed('stomp_front_side',stomp_speed)
	sprite_frames.set_animation_speed('stomp_side',stomp_speed)
func skate_animation(x, z):
	is_playing_fall = false
	if abs(x) < deadzone and abs(z) < deadzone:
		speed_scale = 1.0
		play("skate_idle")
		return

	if x > 0:
		flip_h = false
	if x < 0:
		flip_h = true

	if abs(x) > deadzone and abs(z) > deadzone:
		if z > 0:
			play("skate_down_right")
		else:
			play("skate_up_right")
	elif abs(x) > deadzone:
		play("skate_right")
	else:
		if z > 0:
			play("skate_down")
		else:
			play("skate_up")

#plays the dash_animation depending on direction
func dash_animation(x_dir, z_dir):
	can_play = false
	is_playing_fall = false
	if abs(x_dir) > deadzone and abs(z_dir) > deadzone:
		if z_dir > 0:
			play("dash_front_side")
		else:
			play("dash_back_side")
	elif abs(x_dir) > deadzone:
		play("dash_side")
	else:
		if z_dir > 0:
			play("dash_front")
		else:
			play("dash_back")

func glide_animation(x_dir, z_dir):
	can_play = false
	is_playing_fall = false
	if abs(x_dir) > deadzone and abs(z_dir) > deadzone:
		if z_dir > 0:
			play("glide_front_side")
		else:
			play("glide_back_side")
	elif abs(x_dir) > deadzone:
		play("glide_side")
	else:
		if z_dir > 0:
			play("glide_front")
		else:
			play("glide_back")

func stomp_animation(x_dir, z_dir):
	can_play = false
	is_playing_fall = false
	if abs(x_dir) > deadzone and abs(z_dir) > deadzone:
		if z_dir > 0:
			play("stomp_front_side")
		else:
			play("stomp_back_side")
	elif abs(x_dir) > deadzone:
		play("stomp_side")
	else:
		if z_dir > 0:
			play("stomp_front")
		else:
			play("stomp_back")

func jump_animation(x_dir, z_dir):
	can_play = false
	is_playing_fall = false
	if abs(x_dir) > deadzone and abs(z_dir) > deadzone:
		if z_dir >= 0:
			play("jump_front_side")
		else:
			play("jump_back_side")
	elif abs(x_dir) > deadzone:
		play("jump_side")
	else:
		if z_dir >= 0:
			play("jump_front")
		else:
			play("jump_back")

func fall_animation(x_dir, z_dir):
	if is_playing_fall: 
		return
	is_playing_fall = true
	can_play = false
	if abs(x_dir) > deadzone and abs(z_dir) > deadzone:
		if z_dir >= 0:
			play("fall_front_side")
		else:
			play("fall_back_side")
	elif abs(x_dir) > deadzone:
		play("fall_side")
	else:
		if z_dir >= 0:
			play("fall_front")
		else:
			play("fall_back")

func crash_animation(x_dir, z_dir):
	can_play = false
	is_playing_fall = false
	if abs(x_dir) > deadzone and abs(z_dir) > deadzone:
		if z_dir > 0:
			play("crash_front_side")
		else:
			play("crash_back_side")
	elif abs(x_dir) > deadzone:
		play("crash_side")
	else:
		if z_dir > 0:
			play("crash_front")
		else:
			play("crash_back")
#once an animation is finished the skate animation will be able to play
func _on_animation_finished() -> void:
	can_play = true
