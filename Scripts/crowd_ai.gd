extends Node3D

# EXPORT VARIABLES
@export var circum: float = 10.0
@export var crowd_size: float = 1.0
@export var max_speed: float = 30.0
@export var height_recalc_sensitivity: float = 10.0

# CONSTANTS
const SPEED = 200.0

# LIST INDIVIDUALS
var agents: Array = []
var agents_main: Array = []

# STATES
enum State { IDLE, MOVE, SEARCH, MERGE }
var state : State = State.IDLE

# TIMER
var search_wait_time: float = 1.5 
var search_timer_count: float = 0

# TARGETS
var curr_point = 0
@export var route: Array[Vector3] = [
	Vector3(0,0,0),
	]

# NODE REFERENCE
@onready var navigation_agent_3d: NavigationAgent3D = $Anchor/NavigationAgent3D
@onready var anchor: Node3D = $Anchor
@onready var nav_map = get_world_3d().navigation_map

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print('start')
	group_brain(crowd_size, circum)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	
	match state: 
		State.IDLE:
			get_new_loc()
			print('idle')
		State.MOVE:
			moving_behav()
			print('move')
	
	for child in get_children():
		if child is CharacterBody3D:
			child.move_and_slide()
			child.velocity += child.get_gravity()*1.5 * delta
			print('child')
			print(child.velocity)
			print(child.position)
	
	
	
# functions needed:
# group creation
# indiv creation?
# somehow intergrate with pathfinding?
# reading point to points if given
# moving to hte points (moving behavior)
# merge group (finding behavior)
# delete group (successful merge behavior)
# remove member (collision loss)

# if we are trying to remerge into main group, needs some way of knowing it should be checking that, might need to create sub functions for group brain
 
	
# group brain
# Creates the groups, will need to send a list of what needs to be being checked
# Parameters: 
# - list of individuals
# - size circum
# - either point list which is static, or dynamic point? Most likely, we can find some balance
# - (best solution to the above) toggle for group main or sub
# Return: maybe the list of indivs
func group_brain(count, size, type = 1) -> void:
	if (type == 1):
		for i in range(count):
			create_char(agents)
	print('work')

# main brain
# Main loop for where to go and what to update
# Parameters:
# - Ah
func group_main() -> void:
	print('work')

# sub brain
# Sub loop for remerging, what needs to be initially made and what to follow? (might need to split up again)
# Parameters:
# - Ah
func group_sub() -> void:
	print('work')

# creates a little char body
func create_char(append_target) -> void:
	var character = CharacterBody3D.new()
	var mesh = MeshInstance3D.new()
	var collision = CollisionShape3D.new()
	add_child(character)
	character.add_child(mesh)
	character.add_child(collision)
	
	
	# create for collision box
	var cap = CapsuleShape3D.new()
	cap.radius = 2.0
	cap.height = 10.0
	collision.shape = cap
	
	# create for mesh
	var cap_mesh = CapsuleMesh.new()
	cap_mesh.radius = 2.0
	cap_mesh.height = 10.0
	mesh.mesh = cap_mesh
	
	# create for character
	character.wall_min_slide_angle = 65.0
	character.floor_constant_speed = true
	character.floor_max_angle = 65.0
	character.safe_margin = 3.0
	
	# sets position of body
	print('posit')
	var radi = circum / 2.0
	character.global_position.z = randi_range(global_position.z-radi, global_position.z+radi)
	character.global_position.x = randi_range(global_position.x-radi, global_position.x+radi)
	character.global_position.y = global_position.y
	print(character)
	print(character.position)
	append_target.append(character)
	
	

func get_new_loc() -> void:
	if (navigation_agent_3d.is_navigation_finished()): curr_point += 1
	if (curr_point > route.size()-1): curr_point = 0
	print('get new loc')
	print(curr_point)
	print(route[curr_point])
	navigation_agent_3d.target_position = NavigationServer3D.map_get_closest_point(nav_map, route[curr_point])
	
	print(navigation_agent_3d.target_position)
	if (navigation_agent_3d.target_position != Vector3.ZERO): state = State.MOVE


# moving to hte points (moving behavior)
# merge group (finding behavior)
# delete group (successful merge behavior)
# remove member (collision loss)
# add member (collision gain)
# swap member (comb of del, rmv, and add mem behaviors)

# moving_behav
# depending on type (might make two functions with same name or override) will move to the given target goal with pathfinding (probably just given points individually for modularity)
func moving_behav() -> void: 
	#var nav_map = navigation_agent_3d.get_navigation_map()
	#navigation_agent_3d.target_position = NavigationServer3D.map_get_closest_point(get_world_3d().navigation_map, route[curr_point])
	var current_position = anchor.global_position
	var next_position = navigation_agent_3d.get_next_path_position()
	var direction = (next_position - current_position).normalized()
	var new_velocity = direction * max_speed
	navigation_agent_3d.velocity = new_velocity
	anchor.global_position += direction * max_speed * get_process_delta_time()
	print(new_velocity)
	print(current_position)
	print(next_position)
	if abs(abs(current_position.y) - abs(next_position.y)) > height_recalc_sensitivity: 
		get_new_loc()


# find_group_behav
# Finds the closest (with given size of current subgroup) subgroup and if combined doesn't exceed max size of subgroup
func find_group_behav() -> void:
	print('work')

# delete_group_behav
# Deletes the a group, only call when it either merging with sub group or main group
func delete_group_behav() -> void:
	print('work')

# remove_member_behav
# Removes a member 
func remove_member_behav() -> void:
	print('work')

# add_member_behav
# Adds a member
func add_member_behav() -> void:
	print('work')

# swap_member_behav
# Swaps a member with another group, essentially remove and adding, and possibly deleting if none exist
func swap_member_behav() -> void:
	print('work')
	
	
	
# signals


func _on_navigation_agent_3d_target_reached() -> void:
	state = State.IDLE


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	for child in get_children():
		if child is CharacterBody3D:
			var move_vec = child.velocity.move_toward(safe_velocity, 0.25)
			child.velocity.x = move_vec.x
			child.velocity.z = move_vec.z
			
