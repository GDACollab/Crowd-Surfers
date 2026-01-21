extends CharacterBody3D

#Export variables (add more if needed)
#the max amount of speed the player can reach
@export var max_speed: float = 5.0
#the speed at which the player speeds up
@export var acceleration: float = 20.0
#friction is the speed at which the player decelerates
@export var friction: float = 20.0
#Gravity is currently not doing anything right now
@export var gravity: float = 0.0

@export var JUMP_VELOCITY: float = 4.5

@export var allow_left: bool = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if not allow_left:
		input_dir.x = max(input_dir.x, 0)
		
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		#
		velocity.x = move_toward(velocity.x, direction.x * max_speed, acceleration * delta)
		velocity.z = move_toward(velocity.z, direction.z * max_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.z = move_toward(velocity.z, 0, friction * delta)
	
	
	move_and_slide()
