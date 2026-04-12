extends CharacterBody3D

# CONSTANTS
const SPEED = 50.0

# LIST INDIVIDUALS
var agents: Array = []

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
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print('start')
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	velocity += get_gravity() * delta
	
	match state: 
		State.IDLE:
			get_new_loc()
			print('idle')
		State.MOVE:
			moving_behav()
			print('move')
	move_and_slide()
	
	
	
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
func group_brain(individuals, circum, type = 1) -> void:
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
	

func get_new_loc() -> void:
	curr_point += 1
	print(curr_point)
	if (curr_point > route.size()-1): curr_point = 0
	
	#var target = route[curr_point]
	#print('target')
	#print(target)
	#var nav_map = navigation_agent_3d.get_navigation_map()
	#var safe_target = NavigationServer3D.map_get_closest_point(nav_map, target)
	#print(safe_target)
	
	#navigation_agent_3d.target_position = safe_target
	navigation_agent_3d.target_position = route[curr_point]
	print(navigation_agent_3d.target_position)
	state = State.MOVE


# moving to hte points (moving behavior)
# merge group (finding behavior)
# delete group (successful merge behavior)
# remove member (collision loss)
# add member (collision gain)
# swap member (comb of del, rmv, and add mem behaviors)

# moving_behav
# depending on type (might make two functions with same name or override) will move to the given target goal with pathfinding (probably just given points individually for modularity)
func moving_behav() -> void: 
	var nav_map = navigation_agent_3d.get_navigation_map()
	navigation_agent_3d.target_position = NavigationServer3D.map_get_closest_point(get_world_3d().navigation_map, route[curr_point])
	var current_position = global_transform.origin
	var next_position = navigation_agent_3d.get_next_path_position()
	var direction = (next_position - current_position).normalized()
	var new_velocity = direction * SPEED
	navigation_agent_3d.velocity = new_velocity
	print(new_velocity)
	print(current_position)
	print(next_position)
	#if abs(current_position.y - next_position.y) > 10.0:
		#var nav_map = navigation_agent_3d.get_navigation_map()
		#navigation_agent_3d.target_position = NavigationServer3D.map_get_closest_point(get_world_3d().navigation_map, route[curr_point])


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
	velocity = velocity.move_toward(safe_velocity, 0.25)
	print(velocity)
