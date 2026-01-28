extends CharacterBody3D
@onready var player_sprite: Sprite3D = $Sprite3D

#Export variables (add more if needed)
#the max amount of speed the player can reach
@export var base_max_speed: float = 5.0
#the speed at which the player speeds up

#speed that can be edited by the abilitys.
@export var current_max_speed: float = 5.0

@export var acceleration: float = 20.0
#friction is the speed at which the player decelerates
@export var friction: float = 20.0
#Gravity is currently not doing anything right now
@export var gravity: float = 9.8

@export var JUMP_VELOCITY: float = 4.5

@export var allow_left: bool = false

#for coyote time it is export 
@export var coyote_time: float = 0.5

# bool for while in coyote time
var in_coyote : bool = false 

# bool if jumping
var jumped : bool = false

# bool if have previously coyote jumped
var coyoted : bool = false

func coyote_toggle() -> void:
	if (!coyoted):
		in_coyote = true
		await get_tree().create_timer(coyote_time).timeout 
		in_coyote = false

func _physics_process(delta: float) -> void:
	# Set player sprite offset
	var offset = global_position.y
	player_sprite.position.z = -offset
	
	# Add the gravity.
	if not is_on_floor() :
		velocity += gravity * Vector3.DOWN * delta
		# calls a method that toggle
		# need to make this call once
		coyote_toggle()
		coyoted = true	
		#result = move_toward(current, target, delta)
	else :
		jumped = false
		coyoted = false
	# Handle jump.
	
	if Input.is_action_just_pressed("move_jump") and (is_on_floor() or in_coyote) and !jumped :
		velocity.y = JUMP_VELOCITY
		jumped = true
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if not allow_left:
		input_dir.x = max(input_dir.x, 0)
		
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		#
		velocity.x = move_toward(velocity.x, direction.x * base_max_speed, acceleration * delta)
		velocity.z = move_toward(velocity.z, direction.z * base_max_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.z = move_toward(velocity.z, 0, friction * delta)

	
	move_and_slide()
