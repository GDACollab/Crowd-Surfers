class_name Player
extends CharacterBody3D
@onready var player_sprite: AnimatedSprite3D = $AnimatedSprite3D
var player_sprite_starting_pos: float = 0.0
@onready var raycast : RayCast3D = $CollisionShape3D/RayCast3D
@onready var slope_check_raycast: RayCast3D = $CollisionShape3D/SlopeCheckRaycast
@onready var trail_spakle: AnimatedSprite3D = $TrailSparkle

# STOMP CROWD
signal crowd_stomp_end

# DEBUG
@onready var velocityLabel : Label3D = $VelocityLabel
@onready var stateLabel : Label3D = $StateLabel
@export var debugLabels := true
## Associates each State with a color for debug clarity
var stateColors = {
	States.GROUND : Color.WHITE,
	States.COYOTE : Color.BROWN,
	States.AIR : Color.AQUA,
	States.STOMP_WINDUP : Color.RED,
	States.STOMP_FALL : Color.ORANGE,
	States.GLIDE : Color.BLUE_VIOLET,
	States.DASH_GROUND : Color.GREEN,
	States.DASH_AIR : Color.LIGHT_SEA_GREEN,
	States.SLOPE : Color.BLACK
}

# General movement
@export_category("General Movement")
## The highest value max_speed can be at before modifications
@export var base_ramping_cap: float = 250.0 #the speed at which the player speeds up
## Initial speed when starting from rest
@export var starting_speed : float = 30.0
## Growth exponent for ramping
@export var ramping_exponent: float = 0.5
## Shrinking exponent for damping
@export var damping_exponent: float = 0.5
## Penalty to max speed when crashing into a wall
@export var crash_penalty_mult: float = 1.05
## Acceleration before modifications
@export var base_acceleration: float = 250.0
## Rate at which the player decelerates
@export var friction: float = 200.0
## Added to player's vertical speed in states where they can fall
@export var gravity: float = 500.0
## Time after walking off a ledge that the player can still jump
@export var coyote_time: float = 0.2
## Amount of max speed per second to lose when player is giving no inputs
@export var max_speed_decay: float = 10.0
## Crowd Push force when going through
@export var crowd_push_force: float = 50.0
## Minimum Crowd slowdown
@export var min_crowd_slowdown: float = 0.95
## Maximum Crowd slowdown
@export var max_crowd_slowdown: float = 0.8
##Snap length to ensure smooth movement on slopes
@export var snap_length = 5.0

# Jumping
@export_category("Jumping")
## Speed of the player's jump
@export var jump_speed: float = 180.0
## Gravity during the jump
@export var jump_gravity: float = 350.0
## When jump is let go, set vertical speed to this
@export var jump_end_speed: float = 45.0

# Stomp
@export_category("Stomp")
## Initial speed of the stomp before gravity is applied
@export var stomp_speed: float = 10.0
## The maximum speed that the player can be at on the first frame of the windup
@export var max_speed_for_windup: float = 5.0
## Time it takes the stomp to windup. This should be tied to an animation in the future
@export var windup_duration: float = 0.5
## Rate at which stomp boost accumulates per second
@export var stomp_dash_boost_factor: float = 25.0
## Maximum boost which can be gained from stomp-dashing
@export var max_stomp_dash_boost: float = 40.0
#All tese valuse are for the stomp-launch
#Distance the launch travels
@export var launch_distance: float = 50.0
## Minimum time between dashes
#@export var stomp_launch_cooldown: float = 1.0
## Amount to multiply speed by during dash
@export var launch_speed_multiplier: float = 1.5
## Minimum speed of a dash
@export var min_launch_speed: float = 25.0
## Set to true to always allow air dashing out of stomp
#@export var stomp_resets_air_dash: bool = false
## Amount of time (in seconds) after hitting the ground that the player can dash to restore their speed from before stomping
#@export var stomp_dash_margin: float = 0.2
## Circumference of the Stomp Effect for Crowds
@export var crowd_stomp_radius: float = 50.0
## Strength of the Stomp Effect for Crowds
@export var crowd_stomp_force: float = 50.0
## Multiplier on gravity while in the stomp fall state
@export var stomp_gravity_multiplier: float = 3

# Dash
@export_category("Dash")
## The distance a dash travels
@export var dash_distance: float = 50.0
## Minimum time between dashes
@export var dash_cooldown: float = 1.0
## Amount to multiply speed by during dash
@export var dash_speed_multiplier: float = 1.5
## Minimum speed of a dash
@export var min_dash_speed: float = 25.0
## Set to true to always allow air dashing out of stomp
@export var stomp_resets_air_dash: bool = false
## Amount of time (in seconds) after hitting the ground that the player can dash to restore their speed from before stomping
@export var stomp_dash_margin: float = 0.2
## This minus dash animation time is how long (in seconds) to hold the dash animation after it finishes
@export var dash_animation_hold_time: float = 0.25
## Circumference to check for crowd members when dashing
@export var crowd_dash_radius: float = 15.0
## Strength of the dash Effect for Crowds, overriding to dash speed(?)
@export var crowd_dash_force: float = 100.0
## Minimum number of people required for a dash boost to be applied
@export var crowd_dash_min_members_requirement: int = 5
## tracking variable to determine if you are slowed down by crowd members or not
var has_crowd_dash_boost: bool = false

# Glide
@export_category("Glide")
## Ratio for exponential decay of glide speed
@export var glide_decay_ratio: float = 0.75
## The speed at which glide ends
@export var glide_min_speed: float = 5.0
## Whether glide has gravity
@export var glide_has_gravity: bool = true
## Factor to reduce gravity by during glide
@export var glide_gravity_factor: float = 0.05
## Minimum time (in seconds) that the player can glide for without getting forced out of it
@export var min_glide_time: float = 0.5
# Time between spawning another glide vfx object
@export var time_between_glide_vfx: float = 0.9

# Crash
@export_category("Crash")
## Time (in seconds) the crash state should last
@export var crash_time: float = 0.3
## Factor used to get the speed at which the player should bounce off the wall
@export var crash_bounce_speed_factor: float = 15.0
## The length of the component of the player's velocity into the wall which must be exceeded to register a crash ("how fast into the wall the player is moving")
@export var min_speed_for_crash: float = 100.0

# Shadow
@export_category("Shadow")
@export var shadow_base_scale: float = 1.28      # scale on the ground
@export var shadow_min_scale: float = 0.55       # scale at/above max height
@export var shadow_max_height: float = 3.0       # meters where shadow reaches min scale
@export var shadow_lift: float = 1.5             # your +1.5 offset
@export var shadow_falloff_exp: float = 1.6      # >1 shrinks faster early, <1 shrinks slower

@export_category("VFX")
@export var vfx_manager: Node3D


func _on_stomp_dash_margin_timeout() -> void:
	stomp_boost = 0.0
	max_speed_before_stomp = starting_speed
	velocity_before_stomp = Vector3.ZERO

## Activates when stomping on a Crowd, boosting the player forward and slightly up
func crowd_launch() -> void:
	# Give the player a slight upward bounce so they don't immediately hit the floor
	velocity.y = jump_speed * 0.8 
	
	if not current_state == States.DASH_GROUND:
		speed_before_dashing = Vector2(velocity.x, velocity.z).length()
		stomp_dash_start_pos = position
		# Get directional inputs
		var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		stomp_dash_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		# Ensure speed is at least min_dash_speed and apply stomp_boost
		# The timer handles resetting these values to 0
		stomp_dash_speed = max(min_launch_speed, max_speed * launch_speed_multiplier, velocity_before_stomp.length()) + stomp_boost
		max_speed = max(max_speed, max_speed_before_stomp)
		# If you successfully stomp-dash, retain your speed
		# Apply dash to xz-direction and ignore y component of velocity
		var yspeed := velocity.y
		velocity = stomp_dash_dir * stomp_dash_speed
		velocity.y = yspeed
		# Play dash sound
		$DashSound.play()
		player_sprite.play_animation("dash")

## The states that the player can be in
enum States{GROUND, COYOTE, AIR, STOMP_WINDUP, STOMP_FALL, GLIDE, SLOPE, DASH_GROUND, DASH_AIR, CRASH_AIR, CRASH_GROUND, STOMP_CROWD_LAUNCH}

# Active values - may change during execution
var max_speed: float = starting_speed
var acceleration: float
var ramping_cap: float
var velocity_before_stomp: Vector3
var max_speed_before_stomp: float = starting_speed
var ramping_cap_before_stomp: float
var stomp_windup_slowdown: Vector3
var time_gliding: float = 0.0
var speed_before_gliding: float
var max_speed_before_gliding: float
var glide_vfxs_spawned: int = 0
var stomp_boost: float = 0.0
var speed_before_dashing: float
var dash_dir: Vector3
var dash_speed: float
var dash_start_pos: Vector3
var stomp_dash_speed: float
var stomp_dash_dir: Vector3
var stomp_dash_start_pos: Vector3
var can_air_dash: bool = true
var can_glide: bool = true
var player_height : float
var floor_sound_material: String
var touched_windbox: bool = false
var windbox_boost := Vector3.ZERO
var is_playing_crash: bool = false
var prev_velocity: Vector3

## The current state the player is in
var current_state: int = States.GROUND

func _ready() -> void:
	#aglobal_position = PlayerSpawn.spawnpoint
	# Initiali"res://Scripts/player_controller.gd"ze values
	player_sprite_starting_pos = player_sprite.position.z
	acceleration = base_acceleration
	ramping_cap = base_ramping_cap
	# Initialize timers
	$CoyoteTimer.wait_time = coyote_time
	$StompWindupTimer.wait_time = windup_duration
	$DashCooldownTimer.wait_time = dash_cooldown
	$StompDashMargin.wait_time = stomp_dash_margin
	$DashAnimationEndTimer.wait_time = dash_animation_hold_time
	$CrashTimer.wait_time = crash_time


func _physics_process(delta: float) -> void:
	crowd_slowdown()
	#snap_sprite()
	if touched_windbox:
		velocity += windbox_boost
		touched_windbox = false
	process_state(delta)
	check_state_transitions()
	stick_to_slope()
	prev_velocity = velocity
	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# Did we bump into a car?
		if collider != null and collider.is_in_group("Vehicles"):
			
			# Get the angle of the collision
			var hit_normal = collision.get_normal()
			
			# If the normal's Y value is low, it means we got hit from the SIDE (bumper)
			if hit_normal.y < 0.5: 
				# Call Slip's damage function here! 
				print("Slip got hit by the bumper!")
				# take_damage(1)d
	restart()
	check_height()
	update_fmod_floor_material()
	update_trail(delta)
	if debugLabels:
		update_labels()
	
## Processes the current state. More complicated states have their own child nodes
func process_state(delta: float) -> void:
	match current_state:
		States.GROUND:
			# Ramping
			if max_speed < ramping_cap: 
				max_speed += pow(ramping_cap - max_speed, ramping_exponent) * delta
			else:
				max_speed -= pow(max_speed - ramping_cap, damping_exponent) * delta
			handle_inputs(delta)
			if is_on_floor():
				velocity.y = 0.0
			if not player_sprite.current_animation == "crash_exit":
				if $DashAnimationEndTimer.is_stopped():
					if velocity.length() > 0.0:
						player_sprite.play_animation("skate", true)
					else:
						player_sprite.play_idle_animation()
		States.COYOTE, States.AIR:
			fall(delta)
			handle_inputs(delta)
			# Play fall if the player is moving downwards
			if velocity.y < 0\
			 and $DashAnimationEndTimer.is_stopped()\
			 and not player_sprite.current_animation == "fall"\
			 and not player_sprite.current_animation == "crash":
				player_sprite.play_animation("fall", true)
		States.CRASH_AIR:
			fall(delta)
		States.STOMP_WINDUP:
			# Slow the player down
			velocity.x = move_toward(velocity.x, 0.0, stomp_windup_slowdown.x * delta)
			velocity.z = move_toward(velocity.z, 0.0, stomp_windup_slowdown.z * delta)
		States.STOMP_FALL:
			fall(delta)
			stomp_boost = move_toward(stomp_boost, max_stomp_dash_boost, stomp_dash_boost_factor * delta)
		States.DASH_AIR:
			#fall(delta)
			var magnitude = sqrt(pow(velocity.x,2)+pow(velocity.z,2));
			if (magnitude <= base_ramping_cap/2):
				fall(delta)
			else:
				velocity.y = 0.0
		States.DASH_GROUND:
			velocity.y = 0.0
		States.GLIDE:
			# Increase total time gliding
			time_gliding += delta
			# Get the direction vector for the player's velocity
			var dir := Vector3(velocity.x, 0.0, velocity.z).normalized()
			# Ratio to apply for exponential decay
			var ratio: float = pow(glide_decay_ratio, time_gliding)
			var yspeed := velocity.y
			# Basing the decay off the player's initial speed ensures the glide lasts longer if the
			# player is initially faster, but not too much longer
			velocity = dir * speed_before_gliding * ratio
			# If glide has gravity, we need to keep storing the vertical speed
			if glide_has_gravity:
				velocity.y = yspeed
				fall(delta)
			handle_inputs(delta)
			# Play glide animation
			player_sprite.play_animation("glide", true)
			
			# Spawn glide vfx
			if (time_gliding > time_between_glide_vfx * glide_vfxs_spawned):
				if (vfx_manager == null):
					print("ERROR: No VFX manager assigned to player!!")
				else:
					vfx_manager.spawn_vfx(position, velocity, "glide", self)
				glide_vfxs_spawned += 1
			
		States.STOMP_CROWD_LAUNCH:
			fall(delta)
			handle_inputs(delta)
			
		
## Performs a state transition, if necessary
func check_state_transitions() -> void:
	# Note: I'm almost always giving the stomp priority for state transitions to keep it feeling
	# "snappy". Otherwise, if you let go of glide on the same frame as activating stomp, the stomp
	# wouldn't go off
	# Note 2: make sure only one transition happens per frame by keeping these as if-elif trees
	match current_state:
		States.GROUND:
			if just_crashed():
				transition_to(States.CRASH_GROUND)
			elif Input.is_action_just_pressed("move_jump"):
				jump()
				if can_dash() and Input.is_action_just_pressed("ability_dash"):
					transition_to(States.DASH_AIR)
				else:
					transition_to(States.AIR)
			elif can_dash() and Input.is_action_just_pressed("ability_dash"):
				transition_to(States.DASH_GROUND)
			elif not is_on_floor():
				transition_to(States.COYOTE)
		States.COYOTE:
			if just_crashed():
				transition_to(States.CRASH_AIR)
			elif is_on_floor():
				transition_to(States.GROUND)
			elif Input.is_action_just_pressed("ability_stomp"):
				transition_to(States.STOMP_WINDUP)
			elif $CoyoteTimer.is_stopped():
				transition_to(States.AIR)
			elif can_dash() and can_air_dash and Input.is_action_just_pressed("ability_dash"):
				transition_to(States.DASH_AIR)
			elif Input.is_action_just_pressed("move_jump"):
				jump()
				transition_to(States.AIR)
		States.AIR:
			if just_crashed():
				transition_to(States.CRASH_AIR)
			elif is_on_floor():
				$DashAnimationEndTimer.stop()
				transition_to(States.GROUND)
			elif Input.is_action_just_pressed("ability_stomp"):
				transition_to(States.STOMP_WINDUP)
			elif can_dash() and can_air_dash and Input.is_action_just_pressed("ability_dash"):
				transition_to(States.DASH_AIR)
			elif can_glide and Input.is_action_just_pressed("ability_glide"):
				transition_to(States.GLIDE)
		States.CRASH_AIR:
			if $CrashTimer.is_stopped() and is_on_floor():
				transition_to(States.GROUND)
			elif is_on_floor():
				transition_to(States.CRASH_GROUND)
		States.CRASH_GROUND:
			if $CrashTimer.is_stopped():
				if is_on_floor():
					transition_to(States.GROUND)
			elif not is_on_floor():
				transition_to(States.CRASH_AIR)
		States.STOMP_WINDUP:
			if $StompWindupTimer.is_stopped():
				velocity = Vector3(0.0, -stomp_speed, 0.0)
				crowd_impact()
				transition_to(States.STOMP_FALL)
		States.STOMP_FALL:
			if is_on_floor():
				print("STOMP HIT FLOOR")
				crowd_stomp_end.emit()
				var hit_crowd = false
				
				if (vfx_manager == null):
					print("ERROR: No VFX manager assigned to player!!")
				else:
					vfx_manager.spawn_vfx(position, velocity_before_stomp, "stomp")
				
				# Loop through everything we collided with this frame
				for i in get_slide_collision_count():
					var collision = get_slide_collision(i)
					var collider = collision.get_collider()
					
					print("Collision ", i, " with: ", collider.name)
					print("  - Groups on this object: ", collider.get_groups())
					
					if collider.is_in_group("Crowd"):
						print("Detects Crowd")
						hit_crowd = true
						break
				
				if hit_crowd:
					print("SUCCESS! Crowd object detected. Launching!")
					transition_to(States.STOMP_CROWD_LAUNCH)
					return
				else:
					print("Normal floor detected. Transitioning to GROUND.")
			
				$StompDashMargin.start()
				transition_to(States.GROUND)
			elif Input.is_action_just_pressed("ability_dash"):
				transition_to(States.DASH_AIR)
				# Original behavior if they hit normal ground
				$StompDashMargin.start()
				transition_to(States.GROUND)
			elif Input.is_action_just_pressed("ability_dash"):
				transition_to(States.DASH_AIR)
			elif Input.is_action_just_pressed("ability_dash"):
				transition_to(States.DASH_AIR)
		States.GLIDE:
			if just_crashed():
				transition_to(States.CRASH_AIR)
			elif can_dash() and Input.is_action_just_pressed("ability_dash"):
					transition_to(States.DASH_AIR)
			elif Input.is_action_just_pressed("ability_stomp"):
				transition_to(States.STOMP_WINDUP)
			elif (velocity.length() <= glide_min_speed and time_gliding >= min_glide_time) or Input.is_action_just_released("ability_glide"):# or is_on_wall():
				transition_to(States.AIR)
			elif is_on_floor():
				transition_to(States.GROUND)
			elif is_on_wall():
				transition_to(States.AIR)
		States.DASH_GROUND:
			if just_crashed():
				transition_to(States.CRASH_GROUND)
			else:
				var distance_traveled := dash_start_pos.distance_to(position)
				# Checking for zero velocity accounts for the player hitting dash without a direction
				if distance_traveled >= dash_distance or velocity == Vector3.ZERO:
					if is_on_floor():
						transition_to(States.GROUND)
					else:
						transition_to(States.COYOTE)
				elif Input.is_action_just_pressed("move_jump"):
					jump()
					transition_to(States.AIR)
				elif not is_on_floor():
					transition_to(States.AIR)
		States.DASH_AIR:
			if just_crashed():
				transition_to(States.CRASH_AIR)
			else:
				var distance_traveled := dash_start_pos.distance_to(position)
				#if player is holding space, ignore the below and transition immediately to glide state
				if can_glide and Input.is_action_just_pressed("ability_glide"):
					transition_to(States.GLIDE)
				elif Input.is_action_just_pressed("ability_stomp"):
					transition_to(States.STOMP_WINDUP)
				elif is_on_floor():
					transition_to(States.GROUND)
				# Checking for zero velocity accounts for the player hitting dash without a direction
				elif distance_traveled >= dash_distance or velocity == Vector3.ZERO:
					if is_on_floor():
						transition_to(States.GROUND)
					else:
						transition_to(States.AIR)
		States.STOMP_CROWD_LAUNCH:
			if just_crashed():
				transition_to(States.CRASH_AIR)
			# Allow the player to land, dash, or glide after bouncing
			elif is_on_floor():
				transition_to(States.GROUND)
			elif Input.is_action_just_pressed("ability_stomp"):
				transition_to(States.STOMP_WINDUP)
			elif can_dash() and can_air_dash and Input.is_action_just_pressed("ability_dash"):
				transition_to(States.DASH_AIR)
			elif can_glide and Input.is_action_just_pressed("ability_glide"):
				transition_to(States.GLIDE)

## Actually changes the state, and maintains invariants for each state transition
func transition_to(new_state: int) -> void:
	# Use this match statement to maintain invariants when leaving states
	match current_state:
		States.AIR:
			# Restore friction when leaving the air
			friction *= 2.0
		States.GLIDE:
			# Stop glide sound
			$GlideSound.set_parameter("glide_state", "end")
		States.STOMP_FALL:
			if new_state == States.GROUND:
				# Play end of stomp sound
				$StompSound.set_parameter("stomp_state", "end")
			else:
				# interrupt playback
				$StompSound.stop()
		States.CRASH_GROUND, States.CRASH_AIR:
			if not new_state == States.CRASH_GROUND and not new_state == States.CRASH_AIR:
				velocity *= 0.0
				player_sprite.current_animation = ""
		States.SLOPE:
			var angle: float = get_floor_angle()
			# Sloped movement maintains the velocity but internally multiplies it by the angle,
			# but by default this is not maintained when leaving the slope
			velocity *= cos(angle)
		States.DASH_GROUND:
			has_crowd_dash_boost = false
			if not new_state == States.DASH_AIR:
				# Reset speed if ending a ground dash
				#var yspeed := velocity.y
				#velocity = dash_dir * speed_before_dashing
				#velocity.y = yspeed
				$DashCooldownTimer.start()
		States.DASH_AIR:
			has_crowd_dash_boost = false
			$DashCooldownTimer.start()
		

	# Use this match statement to maintain invariants when entering states
	match new_state:
		States.GROUND:
			can_air_dash = true
			can_glide = true
			# Check if landing sound needs to be played
			if current_state == States.AIR or current_state == States.GLIDE:
				FmodServer.set_global_parameter_by_name_with_label("floor_material", floor_sound_material)
				$LandingSound.play()
			elif current_state == States.CRASH_GROUND or current_state == States.CRASH_AIR:
				#player_sprite.crash_dir = -velocity
				player_sprite.play_animation("crash_exit")
				print("Crash Exit!")
		States.COYOTE:
			$CoyoteTimer.start()
		States.CRASH_GROUND, States.CRASH_AIR:
			if not current_state == States.CRASH_GROUND and not current_state == States.CRASH_AIR:
				max_speed = starting_speed
				var wall_normal := get_wall_normal()
				var speed_into_wall: float = abs(prev_velocity.dot(wall_normal))
				velocity *= -1
				velocity += crash_bounce_speed_factor * log(speed_into_wall) * wall_normal
				$CrashTimer.start()
				player_sprite.crash_dir = -velocity
				player_sprite.play_animation("crash")
				get_viewport().get_camera_3d().apply_shake()
		States.STOMP_WINDUP:
			player_sprite.play_animation("stomp")
			# If dash is active as stomp begins, end it
			$DashCooldownTimer.stop()
			velocity.y = 0.0
			stomp_boost = 0.0
			# If this export var is set, then always allow air dashing out of stomp
			if stomp_resets_air_dash:
				can_air_dash = true
			# Store values needed for the stomp-dash
			velocity_before_stomp = Vector3(velocity.x, 0, velocity.z)	
			max_speed_before_stomp = max(max_speed, starting_speed)
			ramping_cap_before_stomp = ramping_cap
			max_speed = starting_speed
			# Decrease the player's speed if it is too large
			if velocity.length() > max_speed_for_windup:
				velocity = velocity.normalized() * max_speed_for_windup
			# Make this positive so that move_toward always approaches
			stomp_windup_slowdown.x = abs(velocity.x) / windup_duration
			stomp_windup_slowdown.z = abs(velocity.z) / windup_duration
			# Start the windup timer
			$StompWindupTimer.start()
			# Start stomp sound windup
			FmodServer.set_global_parameter_by_name_with_label("floor_material", floor_sound_material)
			$StompSound.set_parameter("stomp_state", "windup")
			$StompSound.play()
			
		States.STOMP_FALL:
			$StompSound.set_parameter("stomp_state", "loop")
		States.GLIDE:
			can_glide = false
			# Player won't fall during glide
			velocity.y = 0.0
			speed_before_gliding = velocity.length()
			max_speed_before_gliding = max_speed
			time_gliding = 0.0
			
			# Start glide sound loop
			$GlideSound.set_parameter("glide_state", "loop")
			$GlideSound.play()
			
			glide_vfxs_spawned = 0
					
		States.AIR:
			# Lower friction in midair
			friction /= 2.0
		States.DASH_GROUND, States.DASH_AIR:
			crowd_dash_check()
			can_air_dash = false
			# Don't reapply dash boost if going from ground dash to air dash
			if not current_state == States.DASH_GROUND:
				speed_before_dashing = Vector2(velocity.x, velocity.z).length()
				dash_start_pos = position
				# Get directional inputs
				var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
				# Don't do any of this logic if the player didn't provide an input with the dash
				if input_dir != Vector2.ZERO:
					dash_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
					# Ensure speed is at least min_dash_speed and apply stomp_boost
					# The timer handles resetting these values to 0
					dash_speed = max(min_dash_speed, max_speed * dash_speed_multiplier, velocity_before_stomp.length()) + stomp_boost
					if(has_crowd_dash_boost): #add crowd dash bonus if this is a crowd dash
						dash_speed += crowd_dash_force
					max_speed = max(max_speed, max_speed_before_stomp)
					# If you successfully stomp-dash, retain your speed
					if not $StompDashMargin.is_stopped():
						max_speed = min(max_speed+stomp_boost,ramping_cap)
						new_state = States.DASH_AIR
					# Apply dash to xz-direction and ignore y component of velocity
					var yspeed := velocity.y
					velocity = dash_dir * dash_speed
					velocity.y = yspeed
					#play dash animation
					player_sprite.play_animation("dash")
					# We want the dash animation to be held for longer than the dash actually lasts cause it's cool asf
					$DashAnimationEndTimer.start()
					
					if (vfx_manager == null):
						print("ERROR: No VFX manager assigned to player!!")
					elif (abs(velocity.z) > abs(velocity.x)):
						vfx_manager.spawn_vfx(position, velocity, "dash_up", self)
					else:
						vfx_manager.spawn_vfx(position, velocity, "dash_side", self)
		
				# Play dash sound
				$DashSound.play()
		States.STOMP_CROWD_LAUNCH:
			crowd_launch()
	
	current_state = new_state

## Handles inputs for standard movement and the dash
func handle_inputs(delta: float) -> void:
	# Get directional inputs
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# if the player stops moving reset the current speed
	if(velocity == Vector3.ZERO): 
		max_speed = starting_speed
	# If there are inputs this frame, direction isn't null, so we add speed
	if direction:
		if player_sprite.current_animation == "crash_exit":
			player_sprite.stop()
			player_sprite.current_animation = ""
		var factorx: float = acceleration * delta
		var factorz: float = acceleration * delta
		
		# Add friction if direction is opposite the velocity for x direction
		if sign(direction.x) != sign(velocity.x):
			factorx += friction * delta
		# Prevents speed loss on any 45 degree turn increments on the x direction
		elif (abs(velocity.x) > abs(direction.x * max_speed) and direction.x != 0 and current_state == States.GROUND):
			velocity.x = direction.x * max_speed
			velocity.z = direction.z * max_speed
		# Add friction if direction is opposite the velocity for z direction
		if sign(direction.z) != sign(velocity.z):
			factorz += friction * delta
		# Prevents speed loss on any 45 degree turn increments on the z direction
		elif (abs(velocity.z) > abs(direction.z * max_speed) and direction.z != 0 and current_state == States.GROUND):
			velocity.x = direction.x * max_speed
			velocity.z = direction.z * max_speed
		# Apply speed
		velocity.x = move_toward(velocity.x, direction.x * max_speed , factorx)
		velocity.z = move_toward(velocity.z, direction.z * max_speed , factorz)
	#Apply friction if no inputs are given
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.z = move_toward(velocity.z, 0, friction * delta)
		max_speed = move_toward(max_speed, starting_speed, max_speed_decay * delta)

## Give the player upwards velocity
func jump() -> void:
	player_sprite.play_animation("jump")
	velocity.y = jump_speed
	$JumpSound.play()
	#Hijacking this to add a check for if you jump off a moving car
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(position, position + 3 * Vector3.DOWN)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	if(!result.is_empty()):
		#We hit something! check if it's an animatablebody,
		#ie could possibly be a moving car
		if(result["collider"].get_class() == "AnimatableBody3D"):
			#Grab it's parent to check if it is a moving car
			var carMover = result["collider"].get_parent()
			if(carMover.has_method("get_player_jumped_velocity")):
				#If it is a moving car, apply the velocity from the car to the player
				var addVelocity = carMover.get_player_jumped_velocity()
				velocity += addVelocity
	

## Called by external objects (like the Wind Box) to force the player into the air
func apply_wind_launch(launch_speed: float) -> void:
	# 1. Apply the speed
	velocity.y = launch_speed
	
	# 2. Force the state machine into the AIR state immediately!
	# This prevents the GROUND state from resetting his y-velocity to 0.0
	transition_to(States.AIR)

## Applies gravity
func fall(delta: float) -> void:
	var gravity_effect := gravity
	if not current_state == States.GLIDE:
		if Input.is_action_pressed("move_jump") and not velocity.y <= jump_end_speed:
			gravity_effect = jump_gravity
		elif Input.is_action_just_released("move_jump") and velocity.y >= jump_end_speed:
			velocity.y = jump_end_speed
	if current_state == States.STOMP_FALL : 
		gravity_effect *= stomp_gravity_multiplier
	elif current_state == States.GLIDE:
		# Decrease gravity
		if glide_has_gravity and velocity.y <= 0.0:
			gravity_effect *= glide_gravity_factor
	velocity += gravity_effect * Vector3.DOWN * delta

## Returns true if the player just crashed into a wall on this frame, and false otherwise
func just_crashed() -> bool:
	# Didn't crash if not on wall
	if not is_on_wall() and not check_crowd_wall:
		return false
	var wall_normal := get_wall_normal()
	var speed_into_wall: float = abs(prev_velocity.dot(wall_normal))
	# Didn't crash if not moving fast enough into the wall
	if speed_into_wall < min_speed_for_crash:
		return false
	# Crashed!
	
	if (vfx_manager == null):
		print("ERROR: No VFX manager assigned to player!!")
	else:
		vfx_manager.spawn_vfx(position, velocity, "bonk")
	
	return true

## Checks player's current height
func check_height() -> void:
	raycast.force_raycast_update()

	if not raycast.is_colliding():
		return

	var ground_point: Vector3 = raycast.get_collision_point()
	player_height = global_position.y - ground_point.y
	
## Checks if player is colliding with a rid (or member of the crowd) and applies force
func check_crowd_wall() -> bool:
	for curr_hit in get_slide_collision_count():
		var collision = get_slide_collision(curr_hit)
		var collider = collision.get_collider_rid()
		if (PhysicsServer3D.body_get_collision_layer(collider) == 4):
			return true 
	return false

## crowd slowdown which gets the current body rid to check if any collisions exist with its mask 4
func crowd_slowdown() -> void:
	if has_crowd_dash_boost: return
	#don't do any crowd slowdown while doing a crowd dash
	var space_state = get_world_3d().direct_space_state
	
	var rid_shape = $CollisionShape3D.shape.get_rid()
	
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape_rid = rid_shape
	query.transform = global_transform
	query.collision_mask = 4
	query.collide_with_bodies = true
	
	var results = space_state.intersect_shape(query, 500)
	var min_actual_slowdown = 1.0 - min_crowd_slowdown
	var max_actual_slowdown = 1.0 - max_crowd_slowdown
	
	
	if results.size() > 0:
		# clamp effect, so although it is the actual slowdown, the higher density the worse effect it has
		var crowd_density = clamp(results.size() * min_actual_slowdown, min_actual_slowdown, max_actual_slowdown)
		velocity *= (1.0 - crowd_density)
		
func crowd_impact() -> void:
	var space_state = get_world_3d().direct_space_state
	
	var blast_shape = SphereShape3D.new()
	var stomp_radius = crowd_stomp_radius
	blast_shape.radius = stomp_radius
	
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = blast_shape
	query.transform = global_transform
	query.collision_mask = 4
	
	var results = space_state.intersect_shape(query, 500)
	for result in results:
		var rid = result.rid
		var manager = result.collider
		# Rid specific ID here
		if manager and manager.has_method("crowd_stomp_spread"):
			manager.crowd_stomp_spread(self, rid, crowd_stomp_force, crowd_stomp_radius)
			
	await crowd_stomp_end
	crowd_stop_impact(results)

func crowd_stop_impact(results) -> void:
	for result in results:
		var rid = result.rid
		var manager = result.collider
		if manager and manager.has_method("crowd_stomp_stop"):
			manager.crowd_stomp_stop(rid)
		

func crowd_dash_check() -> void: 
	var space_state = get_world_3d().direct_space_state
	
	var blast_shape = SphereShape3D.new()
	var dash_radius = crowd_dash_radius
	blast_shape.radius = dash_radius
	
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = blast_shape
	query.transform = global_transform
	query.collision_mask = 4
	
	var results = space_state.intersect_shape(query, 500)
	var personCount = 0
	for result in results:
		var manager = result.collider
		# Rid specific ID here
		if manager and manager.has_method("crowd_stomp_spread"):
			personCount += 1
			if personCount >= crowd_dash_min_members_requirement:
				has_crowd_dash_boost = true
				break;
	
	if personCount < crowd_dash_min_members_requirement:
		has_crowd_dash_boost = false


## Update FMOD floor material parameter based on raycast
func update_fmod_floor_material() -> void:
	
	if not raycast.is_colliding():
		return
	
	var floor_collider = raycast.get_collider()
	if floor_collider.is_in_group("Concrete"):
		floor_sound_material = "concrete"
		#FmodServer.set_global_parameter_by_name_with_label("floor_material", "concrete")
	elif floor_collider.is_in_group("Metal"):
		floor_sound_material = "metal"
		#FmodServer.set_global_parameter_by_name_with_label("floor_material", "metal")
	elif floor_collider.is_in_group("Grass"):
		floor_sound_material = "grass"
		#FmodServer.set_global_parameter_by_name_with_label("floor_material", "grass")

## Returns whether the player is currently dashing
func is_dashing() -> bool:
	return current_state == States.DASH_GROUND or current_state == States.DASH_AIR
	
## Returns whether the player is able to dash
func can_dash() -> bool:
	return not is_dashing() and $DashCooldownTimer.is_stopped()

## Returns the current state
func state_to_string() -> String:
	match current_state:
		States.GROUND:
			return "Ground"
		States.COYOTE:
			return "Coyote"
		States.AIR:
			return "Air"
		States.STOMP_WINDUP:
			return "Windup"
		States.STOMP_FALL:
			return "Stomp"
		States.GLIDE:
			return "Glide"
		States.SLOPE:
			return "Slope"
		States.DASH_GROUND:
			return "Ground Dash"
		States.DASH_AIR:
			return "Air Dash"
		States.STOMP_CROWD_LAUNCH:
			return "Stomp Dash"
		States.CRASH_GROUND:
			return "Ground Crash"
		States.CRASH_AIR:
			return "Air Crash"
	return ""

func update_labels():
	velocityLabel.text = "Velocity: " + str(velocity)
	stateLabel.text = "State: " + state_to_string()
	#stateLabel.modulate = stateColors[current_state]

func stick_to_slope():
	if is_on_floor():
		floor_snap_length = snap_length

func update_trail(delta):
	var inputDir = Input.get_vector("move_left", "move_right", "move_down", "move_up").angle()
	$TrailHolder.rotation.z = lerp_angle($TrailHolder.rotation.z, inputDir, 10 * delta)
	if max_speed > 140:
		$TrailHolder/GPUTrail3D.visible = true
		trail_spakle.visible = true
	else:
		$TrailHolder/GPUTrail3D.restart()
		trail_spakle.visible = false
	#print(max_speed)
	pass

## Checks when the restart button is pressed.
func restart():
	if Input.is_action_just_pressed("restart"):
		# Safely calls the reload scene function.
		call_deferred("reload_scene")

## Reloads the scene, might need to move this to a singleton if needed.
func reload_scene():
	SceneFadeTransition.transition_to_scene(load(get_tree().current_scene.scene_file_path))
	
