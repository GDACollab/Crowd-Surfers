extends CharacterBody3D
@onready var player_sprite: Sprite3D = $Sprite3D
@onready var player_shadow : Sprite3D = $"CollisionShape3D/Drop Shadow"
@onready var raycast : RayCast3D = $CollisionShape3D/RayCast3D

#Export variables (add more if needed)
## The highest value max_speed can be at before modifications
@export var base_ramping_cap: float = 5.0 #the speed at which the player speeds up
@export var starting_speed : float = 1.0
@export var ramping_exponent: float = 0.5
@export var crash_penalty_mult: float = 1.5
## Acceleration before modifications
@export var base_acceleration: float = 20.0
## Rate at which the player decelerates
@export var friction: float = 30.0
@export var drag: float = 10.0
@export var ground_speed_damp: float = 50.0
#Gravity is currently not doing anything right now
@export var gravity: float = 9.8

@export var jump_speed: float = 4.5

@export var stomp_speed: float = 10.0

@export var windup_duration: float = 0.5

#@export var allow_left: bool = false

## Time after walking off a ledge that the player can still jump
@export var coyote_time: float = 0.5

## The maximum speed that the player can be at on the first frame of the windup
@export var max_speed_for_windup: float = 5.0

@export var dash_duration: float = 5.0
@export var dash_cooldown: float = 3.0
@export var dash_speed_multiplier: float = 1.2
@export var dash_boost: float = 5.0
## The time after stomp finishes that the player can activate dash and get an extra boost
@export var stomp_dash_margin: float = 0.1

## When dash ends, reset values and begin the cooldown
func _on_dash_duration_timer_timeout() -> void:
	# Lower max speed to the base if it exceeds it
	acceleration = base_acceleration
	ramping_cap = base_ramping_cap
	max_speed = min(max_speed, ramping_cap)
	# Get xz-velocity unit vector and its length
	var dir := Vector2(velocity.x, velocity.z).normalized()
	var speed = Vector2(velocity.x, velocity.z).length()
	# Lower xz-speed to the maximum if it exceeds it
	velocity.x = min(dir.x * speed, dir.x * max_speed)
	velocity.z = min(dir.y * speed, dir.y * max_speed)
	$DashCooldownTimer.start()

## The states that the player can be in
enum States{GROUND, COYOTE, AIR, STOMP_WINDUP, STOMP_FALL}

# Active values - may change during execution
var max_speed: float = 0.0
var acceleration: float
var ramping_cap: float
var velocity_before_stomp := Vector3(0, 0, 0)
var max_speed_before_stomp: float
var ramping_cap_before_stomp: float
var stomp_windup_slowdown := Vector3(0, 0, 0)

## The current state the player is in
var current_state: int = States.GROUND

func _ready() -> void:
	global_position = PlayerSpawn.spawnpoint
	# Initialize valeus
	acceleration = base_acceleration
	ramping_cap = base_ramping_cap
	# Initialize timers
	$CoyoteTimer.wait_time = coyote_time
	$StompWindupTimer.wait_time = windup_duration
	$DashDurationTimer.wait_time = dash_duration
	$DashCooldownTimer.wait_time = dash_cooldown
	$StompDashMargin.wait_time = stomp_dash_margin
	
	max_speed = starting_speed # this is for ablities to function???

func _physics_process(delta: float) -> void:
	# Set player sprite offset
	var offset = global_position.y
	player_sprite.position.z = -offset
	#print("Player offset", -offset)
	var height = position.y - raycast.get_collision_point().y
	# Drop shadow
	player_shadow.position.z = player_sprite.position.z + 1.5 + height
	height = clampf(height, 0, 0.5)
	var scaleMod= 1.28-height #Should be base scale
	player_shadow.scale = Vector3(scaleMod, scaleMod, scaleMod)
	
	process_state(delta)
	check_state_transitions()
	move_and_slide() #method in GODOT
	
	if (is_on_wall()):
		max_speed = max(ramping_cap / crash_penalty_mult, starting_speed)
		#print("we hit a wall")

## Processes the current state. Will probably be moved to having a node hierarchy, each having its own _process function
func process_state(delta: float) -> void:
	match current_state:
		States.GROUND:
			# Ramping
			if max_speed < ramping_cap: 
				max_speed += pow(ramping_cap - max_speed, ramping_exponent) * delta
			handle_inputs(delta)
		States.COYOTE:
			fall(delta)
			handle_inputs(delta)
		States.AIR:
			fall(delta)
			handle_inputs(delta)
		States.STOMP_WINDUP:
			velocity.x = move_toward(velocity.x, 0.0, stomp_windup_slowdown.x * delta)
			velocity.z = move_toward(velocity.z, 0.0, stomp_windup_slowdown.z * delta)
		States.STOMP_FALL:
			velocity += gravity * Vector3.DOWN * delta
		
## Performs a state transition, if necessary
func check_state_transitions() -> void:
	match current_state:
		States.GROUND:
			if Input.is_action_just_pressed("move_jump"):
				jump()
				transition_to(States.AIR)
			elif not is_on_floor():
				$CoyoteTimer.start()
				transition_to(States.COYOTE)
		States.COYOTE:
			if is_on_floor():
				transition_to(States.GROUND)
			elif Input.is_action_just_pressed("ability_stomp"):
				transition_to(States.STOMP_WINDUP)
			elif $CoyoteTimer.is_stopped():
				transition_to(States.AIR)
			elif Input.is_action_just_pressed("move_jump"):
				jump()
				transition_to(States.AIR)
		States.AIR:
			if is_on_floor():
				transition_to(States.GROUND)
			elif Input.is_action_just_pressed("ability_stomp"):
				transition_to(States.STOMP_WINDUP)
		States.STOMP_WINDUP:
			if $StompWindupTimer.is_stopped():
				velocity = Vector3(0.0, -stomp_speed, 0.0)
				transition_to(States.STOMP_FALL)
		States.STOMP_FALL:
			if is_on_floor():
				$StompDashMargin.start()
				transition_to(States.GROUND)

## Actually changes the state, and maintains invariants for each state transition
func transition_to(new_state: int) -> void:
	# If a state transition must do the exact same thing regardless of the starting state,
	# add it to this match tree
	match new_state:
		States.STOMP_WINDUP:
			# If dash is active as stomp begins, end it
			if not $DashDurationTimer.is_stopped():
				$DashDurationTimer.stop()
				$DashDurationTimer.timeout.emit()
			velocity.y = 0.0
			velocity_before_stomp = velocity
			max_speed_before_stomp = max_speed
			ramping_cap_before_stomp = ramping_cap
			print("Speed before stomp: %f" % velocity_before_stomp.length())
			# Decrease the player's speed if it is too large
			if velocity.length() > max_speed_for_windup:
				velocity = velocity.normalized() * max_speed_for_windup
			# Make this positive so that move_toward always approaches
			stomp_windup_slowdown.x = velocity.x / windup_duration * sign(velocity.x)
			stomp_windup_slowdown.z = velocity.z / windup_duration * sign(velocity.z)
			$StompWindupTimer.start()
			
	current_state = new_state
	print_state()

func print_state() -> void:
	match current_state:
		States.GROUND:
			print("Ground")
		States.COYOTE:
			print("Coyote")
		States.AIR:
			print("Air")
		States.STOMP_WINDUP:
			print("Windup")
		States.STOMP_FALL:
			print("Stomp")

func handle_inputs(delta: float) -> void:
	# Get directional inputs
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	# Activate dash
	if $DashDurationTimer.is_stopped() and $DashCooldownTimer.is_stopped() and Input.is_action_just_pressed("ability_dash"):
		dash(Vector3(input_dir.x, 0.0, input_dir.y).normalized())
	# If dash wasn't activated this frame, do normal inputs
	else:
		if(velocity == Vector3.ZERO): # if the player stops moving reset the current speed
			max_speed = starting_speed
		if direction:
			velocity.x = move_toward(velocity.x, direction.x * max_speed , acceleration * delta)
			velocity.z = move_toward(velocity.z, direction.z * max_speed , acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, friction * delta)
			velocity.z = move_toward(velocity.z, 0, friction * delta)
		
func dash(dir: Vector3) -> void:
	# Increase caps
		ramping_cap = ramping_cap * dash_speed_multiplier + dash_boost
		max_speed = move_toward(max_speed * dash_speed_multiplier, ramping_cap, dash_boost)
		# Increase acceleration
		acceleration *= dash_speed_multiplier
		# Apply instant boost (and redirect player) if directional inputs are given
		if dir:
			var speed: float = 0.0
			# If we just hit the ground after stomping, restore the player's speed from before the stomp
			if not $StompDashMargin.is_stopped():
				speed = velocity_before_stomp.length()
				ramping_cap = max(ramping_cap, ramping_cap_before_stomp * dash_speed_multiplier + dash_boost)
				max_speed = max(max_speed, max_speed_before_stomp * dash_speed_multiplier + dash_boost)
			else:
				speed = Vector3(velocity.x, 0.0, velocity.z).length()
			var boost: float = speed + dash_boost
			velocity.x = move_toward(0.0, dir.x * max_speed, abs(dir.x) * boost)
			velocity.z = move_toward(0.0, dir.z * max_speed, abs(dir.z) * boost)
		print("Speed after dash: %f" % velocity.length())
		# Start duration timer
		$DashDurationTimer.start()

func jump() -> void:
	velocity.y = jump_speed

func fall(delta: float) -> void:
	velocity += gravity * Vector3.DOWN * delta
	velocity.x = move_toward(velocity.x, 0, drag * delta)
	velocity.z = move_toward(velocity.z, 0, drag * delta)

#Called by checkpoints
func set_spawnpoint(new_spawnpoint: Vector3) -> void:
	PlayerSpawn.spawnpoint = new_spawnpoint
