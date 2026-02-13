extends CharacterBody3D
@onready var player_sprite: Sprite3D = $Sprite3D
@onready var player_shadow : Sprite3D = $"CollisionShape3D/Drop Shadow"
@onready var raycast : RayCast3D = $CollisionShape3D/RayCast3D

#Export variables (add more if needed)
#the max amount of speed the player can reach
@export var base_max_speed: float = 5.0 #the speed at which the player speeds up
@export var current_max_speed: float = 0.0 #speed that can be edited by the abilitys.
@export var starting_speed : float = 1.0
@export var ramping_exponent: float = 0.5
@export var crash_penalty_mult: float = 1.5

@export var acceleration: float = 20.0
#friction is the speed at which the player decelerates
@export var friction: float = 30.0
@export var air_speed_damp: float = 10.0
@export var ground_speed_damp: float = 50.0
#Gravity is currently not doing anything right now
@export var gravity: float = 9.8

@export var JUMP_VELOCITY: float = 4.5

#@export var allow_left: bool = false

#for coyote time it is export 
@export var coyote_time: float = 0.5
	
# bool for while in coyote time
var in_coyote : bool = false 

# bool if jumping
var jumped : bool = false


var coyoted : bool = false# bool if have previously coyote jumped

func _ready() -> void:
	global_position = PlayerSpawn.spawnpoint
	
	current_max_speed = starting_speed # this is for ablities to function???
	
func coyote_toggle() -> void:
	if (!coyoted):
		in_coyote = true
		await get_tree().create_timer(coyote_time).timeout 
		in_coyote = false

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
	
	# Add the gravity.
	
	#if we r on the ground if current max speed is less than base max speed then increase it
	#if current is high than basemax speed bring it down to basemax speed
	if not is_on_floor() :
		#current_max_speed = min(base_max_speed,current_max_speed)
		velocity += gravity * Vector3.DOWN * delta
		velocity.x = move_toward(velocity.x, 0, air_speed_damp * delta)
		velocity.z = move_toward(velocity.z, 0, air_speed_damp * delta)
		coyote_toggle()
		coyoted = true	
		#result = move_toward(current, target, delta)
	else :
		jumped = false # Handle jump.
		coyoted = false
		if(current_max_speed < base_max_speed): 
			#decrease it
			current_max_speed += pow(base_max_speed - current_max_speed, ramping_exponent) * delta
		
	
	
	if Input.is_action_just_pressed("move_jump") and (is_on_floor() or in_coyote) and !jumped :
		velocity.y = JUMP_VELOCITY
		jumped = true
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	#if not allow_left:
		#input_dir.x = max(input_dir.x, 0)
		
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if(velocity == Vector3.ZERO): # if the player stops moving reset the current speed
		current_max_speed = starting_speed
	if direction:
		velocity.x = move_toward(velocity.x, direction.x * current_max_speed , acceleration * delta)
		velocity.z = move_toward(velocity.z, direction.z * current_max_speed , acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.z = move_toward(velocity.z, 0, friction * delta)
		#if curent max speed is higher than base_max_speed lower current back down to base_max speed
	print(current_max_speed)
	move_and_slide() #method in GODOT
	
	if (is_on_wall()):
		current_max_speed = max(base_max_speed / crash_penalty_mult, starting_speed)
		print("we hit a wall")


#Called by checkpoints
func set_spawnpoint(new_spawnpoint: Vector3) -> void:
	PlayerSpawn.spawnpoint = new_spawnpoint
