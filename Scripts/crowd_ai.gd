extends Node3D

# EXPORT VARIABLES
@export var circum: float = 10.0
@export var crowd_size: float = 1.0
@export var max_speed: float = 20.0
@export var acceleration: float = 5.0
@export var height_recalc_sensitivity: float = 10.0

# LIST INDIVIDUALS
var agents: Array = []
var agents_main: Array = []
var agents_sub: Array = []

# STATES
enum State { IDLE, MOVE, SEARCH, MERGE }
var state : State = State.IDLE

# TIMER
var search_wait_time: float = 1.5 
var search_timer_count: float = 0

var sub_update_time: float = 3.0
var sub_timer_count: float = 2.0

# ANCHOR VARIABLES
var anchor_velocity = Vector3(0, 0, 0)

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
	navigation_agent_3d.max_speed = max_speed
	var anchor_mesh = $Anchor/MeshInstance3D
	var area = CylinderMesh.new()
	area.top_radius = circum / 2.0
	area.bottom_radius = circum / 2.0
	
	anchor_mesh.mesh = area
	
	agents_main.append(anchor)
	
	group_brain(crowd_size, circum)
	group_brain(1, circum, 0)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	# move behaviors
	match state: 
		State.IDLE:
			get_new_loc()
			for nav in agents_sub:
				print(get_node(nav[0].name + "/SubNav"))
				get_new_sub_loc(get_node(nav[0].name + "/SubNav"))
		State.MOVE:
			moving_behav(anchor, navigation_agent_3d)
			for nav in agents_sub:
				var nav_agent = get_node(nav[0].name + "/SubNav")
				moving_behav(nav[0], nav_agent)
				
				# timer for new position
				if (sub_timer()): get_new_sub_loc(nav_agent)
	
	
	# agent behavior
	for agt in agents_main:
		agt.move_and_slide()
		agt.velocity += agt.get_gravity()*10 * delta
	for agt_array in agents_sub:
		var nav_agent = get_node(agt_array[0].name + "/SubNav")
		for agt in agt_array:
			agt.move_and_slide()
			agt.velocity += agt.get_gravity()*10 * delta
	

	
	
	
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
			create_char_mesh(create_char(agents_main))
			
	else:
		create_sub_group(0)
		for i in range(count):
			create_char_mesh(create_char(agents_sub[0]))

# main brain
# Main loop for where to go and what to update
# Parameters:
# - Ah
func group_main(safe_velocity) -> void:
	var vel = anchor.velocity.move_toward(safe_velocity, acceleration * get_physics_process_delta_time())
	print('velll')
	for agt in agents_main:
		agt.velocity.x = vel.x
		agt.velocity.z = vel.z
		print(agt.velocity)

# sub brain
# Sub loop for remerging, what needs to be initially made and what to follow? (might need to split up again)
# Parameters:
# - Ah
func group_sub(sub_index, safe_velocity) -> void:
	var vel = agents_sub[sub_index][0].velocity.move_toward(safe_velocity, acceleration * get_physics_process_delta_time())
	for agt in agents_sub[sub_index]:
		agt.velocity.x = vel.x
		agt.velocity.z = vel.z
		print(agt.velocity)

# creates a little char body
func create_char(append_target, name = "crowd") -> MeshInstance3D:
	var character = CharacterBody3D.new()
	character.name = name
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
	
	# create for character
	character.wall_min_slide_angle = 65.0
	character.floor_constant_speed = true
	character.floor_max_angle = 65.0
	character.safe_margin = 0.5
	character.add_collision_exception_with(anchor)
	
	# sets position of body
	print('posit')
	var radi = circum / 2.0
	character.global_position.z = randi_range(global_position.z-radi, global_position.z+radi)
	character.global_position.x = randi_range(global_position.x-radi, global_position.x+radi)
	character.global_position.y = global_position.y + 1
	print(character)
	print(character.position)
	append_target.append(character)
	return mesh
	
	
func create_char_mesh(mesh) -> void:
	# create for mesh
	var cap_mesh = CapsuleMesh.new()
	cap_mesh.radius = 2.0
	cap_mesh.height = 10.0
	mesh.mesh = cap_mesh
	
func create_anchor_mesh(mesh) -> void:
	var area = CylinderMesh.new()
	area.top_radius = circum / 2.0
	area.bottom_radius = circum / 2.0
	
	mesh.mesh = area
	mesh.transparency = 0.1
	

#agent.signal_name.connect(_function_name)
func create_sub_group(sub_idx = 0) -> void:
	var nav_agent = navigation_agent_3d.duplicate()
	nav_agent.name = "SubNav"
	nav_agent.max_speed = max_speed * 1.5
	var sub_array = []
	create_anchor_mesh(create_char(sub_array, "AnchorSub"))
	agents_sub.insert(sub_idx, sub_array)
	var sub_anchor = agents_sub[sub_idx][0]
	add_child(sub_anchor)
	sub_anchor.add_child(nav_agent)
	nav_agent.velocity_computed.connect(
		func(safe_velocity: Vector3):
			_on_velocity_computed(safe_velocity, sub_idx))


func get_new_loc() -> void:
	if (navigation_agent_3d.is_navigation_finished()): curr_point += 1
	if (curr_point > route.size()-1): curr_point = 0
	print('get new loc')
	navigation_agent_3d.target_position = NavigationServer3D.map_get_closest_point(nav_map, route[curr_point])
	
	print(navigation_agent_3d.target_position)
	if (navigation_agent_3d.target_position != Vector3.ZERO): state = State.MOVE


func get_new_sub_loc(given_agent) -> void:
	print('get new sub loc')
	given_agent.target_position = NavigationServer3D.map_get_closest_point(nav_map, anchor.global_position)
	#if (navigation_agent_3d.target_position != Vector3.ZERO): state = State.MOVE
	

# moving to the points (moving behavior)
# merge group (finding behavior)
# delete group (successful merge behavior)
# remove member (collision loss)
# add member (collision gain)
# swap member (comb of del, rmv, and add mem behaviors)

# moving_behav
# depending on type (might make two functions with same name or override) will move to the given target goal with pathfinding (probably just given points individually for modularity)
func moving_behav(anchor_given, agent) -> void: 
	#var nav_map = navigation_agent_3d.get_navigation_map()
	#navigation_agent_3d.target_position = NavigationServer3D.map_get_closest_point(get_world_3d().navigation_map, route[curr_point])
	var current_position = anchor_given.global_position
	var next_position = agent.get_next_path_position()
	var direction = (next_position - current_position).normalized()
	var new_velocity = direction * max_speed
	agent.set_velocity(new_velocity)
	#if abs(abs(current_position.y) - abs(next_position.y)) > height_recalc_sensitivity: 
		#get_new_loc()


# find_group_behav
# Finds the closest (with given size of current subgroup) subgroup and if combined doesn't exceed max size of subgroup
func find_group_behav(crowd_size) -> void:
	print('work')

# delete_group_behav
# Deletes the a group, only call when it either merging with sub group or main group
func delete_group_behav(member, target) -> void:
	print('work')

# remove_member_behav
# Removes a member 
func remove_member_behav(member_idx, target) -> void:
	target.remove_at(member_idx)
	print('remove')

# add_member_behav
# Adds a member
func add_member_behav(member, target) -> void:
	target.append(member)
	print('add')

# swap_member_behav
# Swaps a member with another group, essentially remove and adding, and possibly deleting if none exist
func swap_member_behav(source, member, member_idx, target) -> void:
	var temp = member
	var temp_idx = member_idx
	remove_member_behav(member_idx, source)
	add_member_behav(member, target)
	print('swapped')
	
	
	
## timers
func sub_timer() -> bool:
	sub_timer_count+=get_physics_process_delta_time()
	if (sub_timer_count > sub_update_time):
		sub_timer_count = 0
		return true
	return false
func search_timer() -> bool:
	search_timer_count+=get_physics_process_delta_time()
	if (search_timer_count > search_wait_time):
		search_timer_count = 0
		return true
	return false


## signals
func _on_navigation_agent_3d_target_reached() -> void:
	state = State.IDLE

# main nav agent
func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	group_main(safe_velocity)

# relative sub nav agent
func _on_velocity_computed(safe_velocity: Vector3, sub_idx) -> void:
	print('vel comp')
	print(safe_velocity)
	group_sub(sub_idx, safe_velocity)
