extends Node3D

# EXPORT VARIABLES
@export var circum: float = 10.0 # area of main brain
@export var ratio_circum: float = 0.5 # area ratio of subgroups max, and max find distance
@export var crowd_size: float = 1.0
@export var max_speed: float = 20.0
@export var acceleration: float = 20.0
@export var height_recalc_sensitivity: float = 10.0
@export var check_rate: int = 200
@export var check_limit: int = 2
@export var crowd_image: Texture2D

# ARRAY
var agents_main: Array = []
var agents_sub: Array = []
var deletion_queue: Array = []
var moved_data: Array = []
var call_queue: Array = []

# STATES
enum State { IDLE, MOVE, SEARCH, MERGE }
var state : State = State.IDLE

# TIMER
var check_update_time: float = 2.0
var check_timer_count: float = 0.0

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
	navigation_agent_3d.radius = circum / 2.0
	var anchor_mesh = $Anchor/MeshInstance3D
	var anchor_box = $Anchor/CollisionShape3D
	#anchor_box.shape.radius = circum / 2.0
	#anchor_box.shape.radius = circum / 4.0

	var area = CylinderMesh.new()
	area.top_radius = circum / 2.0
	area.bottom_radius = circum / 2.0
	
	anchor_mesh.mesh = area
	
	agents_main.append(anchor)
	anchor.set_meta("curr_circum", circum)
	
	#var root = get_tree().root
	#anchor.add_collision_exception_with(root.find_child("Player"))
	
	group_brain(crowd_size, circum, 1)
	#group_brain(1, circum, 0)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#print('one loop')
	# move behaviors
	match state: 
		State.IDLE:
			get_new_loc()
			for nav in agents_sub:
				#print(get_node(nav[0].name + "/SubNav"))
				get_new_sub_loc(get_node(nav[0].name + "/SubNav"))
		State.MOVE:
			#print('movee')
			group_main(moving_behav(anchor, navigation_agent_3d))
			#moving_behav(anchor, navigation_agent_3d)
			for nav in agents_sub:
				var nav_agent = get_node(nav[0].name + "/SubNav")
				
				var vel = moving_behav(nav[0], nav_agent)
				#print(vel)
				
				# timer for new position
				if (sub_timer()): get_new_sub_loc(nav_agent)
	
	#print(agents_main)
	#print(agents_sub)
	# agent behavior
#	# possibly move move_and_collide to group main/sub calls for velocity
	checkAmor(agents_main, false)
	for agt_idx in range(agents_main.size()-1,-1,-1):
		var agt = agents_main[agt_idx]
		agt.move_and_slide()
		agt.velocity += agt.get_gravity()*10 * delta
		#print(agt_idx)
		#if (agt_idx != 0): checkWall(agents_main, agt)
	
	for idx in range(agents_sub.size()-1,-1,-1):
		var agt_array = agents_sub[idx]
		checkAmor(agt_array, true)
		
		for agt_idx in range(agt_array.size()-1,-1,-1):
			var agt = agt_array[agt_idx]
			agt.move_and_slide()
			agt.velocity += agt.get_gravity()*10 * delta
			#print(agt_idx)
			#if (agt_idx != 0): checkWall(agt_array, agt)
	
	# call all swaps (maybe do this before find instead of swap)
	for c in call_queue:
		if c.is_valid():
			c.call()
	call_queue.clear()
	
	# deletion for all in queue
	delete_queue()
	# reset move_data ref and clear currently checked references
	#print(agents_main)
	#print(agents_sub)

	
	
	
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
func group_brain(count, size, type = 1, position = Vector3(0,0,0) ) -> Array:
	const member_rad = 2
	if (type == 1):
		for i in range(count):
			create_char_mesh(create_char(agents_main), member_rad)
		
		return []
	else:
		var new_idx = agents_sub.size()
		var new_sub = create_sub_group(position, new_idx)
		return new_sub
	return []

# main brain
# Main loop for where to go and what to update
# Parameters:
# - Safe_velocity: Velocity to apply to the agents
func group_main(safe_velocity) -> void:
	#var target_vel = safe_velocity
	#if target_vel.length() < 0.1:
	#	target_vel = (navigation_agent_3d.get_next_path_position() - anchor.global_position).normalized() * max_speed
	var vel = anchor.velocity.move_toward(safe_velocity, acceleration * get_physics_process_delta_time())
	#print(vel)
	for agt in agents_main:
		agt.velocity.x = vel.x
		agt.velocity.z = vel.z


# sub brain
# Sub loop for remerging, what needs to be initially made and what to follow? (might need to split up again)
# Parameters:
# - Sub_index: reference to where sub brain is placed in array
# - Safe_velocity: Velocity to apply to the agents
func group_sub(sub_array, safe_velocity) -> void:
	if (sub_array.is_empty()): return
	#var target_vel = safe_velocity
	#if target_vel.length() < 0.1:
		#target_vel = (sub_array[0].get_node_or_null("SubNav").get_next_path_position() - sub_array[0].global_position).normalized() * max_speed
	var vel = sub_array[0].velocity.move_toward(safe_velocity, acceleration * 1.25 * get_physics_process_delta_time())
	
	for agt in sub_array:
		if (not is_instance_valid(agt)): continue
		agt.velocity.x = vel.x
		agt.velocity.z = vel.z

## collision detection
# checkCollision
# Checks whether to apply which every necessary effect (bounce or slide). Helps to apply physics
# Parameters: 
# - source (member)
# - target (member, wall, player)
# - collision itself
# Returns: 
# - Finds which type of collision and what to call for interaction for movement
# WIP
func checkCollision(source, target, collision) -> void:
	if target.name == "Player":
		print("player, always bounce")
		bounce_behav(source, collision)
		bounce_behav(target, collision)
		
	elif target is CharacterBody3D:
		print("crowd, may involve either slide or none?")
		# calculate the vector of velocity in relation to one another
		# depending on velocity direction, either push or slide, or no connection
		
	else:
		print("world, basic slide")
		#slide_behav(source, collision)

# checkWall
# Checks if the current collisions of member given satisfies checking distance from group
func checkWall(origin, member) -> void:
	#if (!member.is_on_wall()): return
	for curr_hit in member.get_slide_collision_count():
		var collision = member.get_slide_collision(curr_hit)
		var target = collision.get_collider()
		var hit_point = collision.get_position()
		var local_hit = member.to_local(hit_point)
		print(collision)
		checkCollision(origin, target, collision)
		
		#if (local_hit.z < -0.1 or local_hit.x > 0.1 or local_hit.x < -0.1):
			#if (member.global_position.distance_squared_to(anchor.global_position) >= circum): 
				#find_group_behav(member, origin, 0)
# checkAmor
# Checks the given array, through amortization. Searches for missing from the main group, or if it is near the main group
# convert to multi functions
func checkAmor(array, non_main) -> void:
	if array.size() <= 1: return
	var check_freq = Time.get_ticks_msec() / check_rate
	# will never be 0 (good for anchor)
	# check through member in given freq, to see if member is outside of given group or at anchor
	for i in range(check_limit):
		var check_index = (check_freq + i) % array.size()
		if check_index == 0: continue
		var member = array[check_index]
		
		if not is_instance_valid(array[0]): return
		var member_position = Vector2(member.global_position.x, member.global_position.z)
		if (is_instance_valid(member) and member_position.distance_to(Vector2(array[0].global_position.x, array[0].global_position.z)) >= circum / 2.0):
			find_group_behav(array[check_index], array, 0)
			return
		if (is_instance_valid(member) and non_main and member_position.distance_to(Vector2(anchor.global_position.x, anchor.global_position.z)) < circum / 2.0):
			call_queue.append(Callable(self, "swap_member_behav").bind(array, member, agents_main))
			return
	# returns if main anchor, since main anchor should not merge
	if (!non_main and agents_sub.size() <= 0): return
	
	# check through each sub anchor to see if the sub groups can merge
	var check_size = check_limit % agents_sub.size()
	for i in range(check_size):
		#print(check_size)
		#print(agents_sub.size())
		var check_index = (check_freq + i) % agents_sub.size()
		var sub_group = agents_sub[i]
		
		if not is_instance_valid(array[0]): return
		var given_anchor_position = Vector2(array[0].global_position.x, array[0].global_position.z)
		#print('sub_anc')
		#print(given_anchor_position.distance_to(Vector2(sub_group[0].global_position.x, sub_group[0].global_position.z)))
		if (array.size() > sub_group.size() and given_anchor_position.distance_to(Vector2(sub_group[0].global_position.x, sub_group[0].global_position.z)) < circum / 3.0):
			#print('working anchor given')
			call_queue.append(Callable(self, "mass_swap_behav").bind(array, sub_group))
			return
	
	
# checkMerge
func checkMerge(member, array) -> void: 
	if (member.global_position.distance_to(anchor.global_position) < circum):
		call_queue.append(Callable(self, "swap_member_behav").bind(array, member, agents_main))
		
	else:
		for sub_array in agents_sub:
			if (member.global_position.distance_to(sub_array[0].global_position) < circum):
				call_queue.append(Callable(self, "swap_member_behav").bind(array, member, sub_array))
				break

# checkAnchor
# Checks the given anchor to all sub_anchors to determine if a merge is acceptable
func checkAnchor(array) -> void:
	if (array[0].global_position.distance_to(anchor.global_position) < circum / 2.0):
			call_queue.append(Callable(self, "swap_member_behav").bind(array, array[0], 0, anchor))
	
	for sub_group in agents_sub:
		if (sub_group == array): continue
		if (array[0].global_position.distance_to(sub_group[0].global_position) < circum / 2.0):
			call_queue.append(Callable(self, "swap_member_behav").bind(array, array[0], 0, sub_group[0]))
		
	


# finds a new location for nav agent with a given point to point system
# Bug:
# - Currently, it will need to recalculate the path if it is underneath the current height, since often times it doesn't recalculate when it needs to
func get_new_loc() -> void:
	if (navigation_agent_3d.is_navigation_finished()): curr_point += 1
	if (curr_point > route.size()-1): curr_point = 0
	#print('get new loc')
	navigation_agent_3d.target_position = NavigationServer3D.map_get_closest_point(nav_map, route[curr_point])
	
	if (navigation_agent_3d.target_position != Vector3.ZERO): state = State.MOVE


# simplier nav locator for sub groups
func get_new_sub_loc(given_agent) -> void:
	#print('get new sub loc')
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
func moving_behav(anchor_given, agent) -> Vector3: 
	#var nav_map = navigation_agent_3d.get_navigation_map()
	#navigation_agent_3d.target_position = NavigationServer3D.map_get_closest_point(get_world_3d().navigation_map, route[curr_point])
	var current_position = anchor_given.global_position
	var next_position = agent.get_next_path_position()
	var direction = (next_position - current_position).normalized()
	#print(current_position)
	#print(next_position)
	var new_velocity = direction * agent.max_speed
	agent.set_velocity(new_velocity)
	#agent.target_velocity = new_velocity
	#anchor_given.velocity = anchor_given.velocity.move_toward(new_velocity, acceleration * get_physics_process_delta_time())
	if anchor_given == anchor and abs(abs(current_position.y) - abs(next_position.y)) > height_recalc_sensitivity: 
		get_new_loc()
	return new_velocity
		
# bounce_behav
# Applies normal of collision to veloicty when bumping into a player.
# Parameters:
# - member: crowd individual to be affected
# - collision: reference to the move_and_collide
# Returns:
# - calculated bounce velocity of given object
func bounce_behav(member, collision) -> Vector3:
	print('bounce')
	print(collision)
	member.velocity = member.velocity.bounce(collision.get_normal())
	return member.velocity

# find_group_beh=v
# Finds the closest (with given size of current subgroup) subgroup and if combined doesn't exceed max size of subgroup
func find_group_behav(member, origin, crowd_size) -> void:
	#print('find')
	for agt_array in agents_sub:
		var dist = member.global_position.distance_to(agt_array[0].global_position)
		var temp_circum = circum * ratio_circum
		var new_circum = agt_array[0].get_meta("curr_circum") + dist
		# check if objectect is close and combining doesn't exceed limit
		if (dist <= temp_circum) and new_circum <= temp_circum:
			call_queue.append(Callable(self, "swap_member_behav").bind(origin, member, agt_array))
			agt_array[0].set_meta("curr_circum", new_circum)
			return
	var new_sub = group_brain(0, 0, 0, member.global_position)
	call_queue.append(Callable(self, "swap_member_behav").bind(origin, member, new_sub))

# delete_group_behav
# Deletes the a group, only call when it either merging with sub group or main group
func delete_group_behav(target) -> void:
	if (target == agents_main or target.size() > 1): return
	
	if target.is_empty():
		agents_sub.erase(target)
		return
	
	var nav_agent = target[0]
	var nav_node = nav_agent.get_node_or_null("SubNav")
	if (is_instance_valid(nav_node) and nav_node.velocity_computed.is_connected(_on_velocity_computed)):
		nav_node.velocity_computed.disconnect(_on_velocity_computed)
	if (is_instance_valid(nav_agent)):
		nav_agent.queue_free()
	
	agents_sub.erase(target)
	#print('delete')
	
# delete_queue
# Goes through the queue to call deletion on groups
func delete_queue() -> void:
	for del in deletion_queue:
		delete_group_behav(del)
	deletion_queue.clear()

# remove_member_behav
# Removes a member 
func remove_member_behav(member_idx, target) -> void:
	target.remove_at(member_idx)
	#print('remove')

# add_member_behav
# Adds a member
func add_member_behav(member, target) -> void:
	target.append(member)
	target[0].add_collision_exception_with(member)
	#print('add')

# swap_member_behav
# Swaps a member with another group, essentially remove and adding, and possibly deleting if none exist
func swap_member_behav(source, member, target) -> void:
	if (!member or !source): return
	var temp_idx = source.find(member)
	add_member_behav(member, target)
	remove_member_behav(temp_idx, source)
	
	#if (source.size() == 1 and source != agents_main): delete_group_behav(source) # safety to prevent deleting an anchor yet
	if (source.size() == 1 and source != agents_main): deletion_queue.append(source)
	print('swapped')
	
# mass_swap_behav
# Swaps massive group, calling the swap member, but does so without needing to store tons of function calls
func mass_swap_behav(array, target) -> void:
	if (!array or !target): return
	
	# only swap if the member is in range of target's cirucm
	var target_anchor = Vector2(target[0].global_position.x, target[0].global_position.z)
	for member_idx in range(array.size() -1, 0, -1):
		var member = array[member_idx]
		if (target_anchor.distance_to(Vector2(member.global_position.x, member.global_position.z)) < circum / 2.0):
			swap_member_behav(array, member, target)
	
	# reposition the current anchor to the last unswapped member if it exists
	if (target.size() > 1):
		target[0].global_position = target[1].global_position


# creats a sub group array with an anchor
func create_sub_group(location, sub_idx = 0) -> Array:
	#print('sub group')
	var nav_agent = navigation_agent_3d.duplicate()
	nav_agent.name = "SubNav"
	nav_agent.avoidance_enabled = true
	nav_agent.max_speed = max_speed * 1.5
	nav_agent.neighbor_distance = 0
	#nav_agent.avoidance_priority = 0.0
	#nav_agent.avoidance_mask = 0b10
	var sub_array = []
	create_anchor_mesh(create_char(sub_array, "AnchorSub"), circum * ratio_circum)
	agents_sub.insert(sub_idx, sub_array)
	var sub_anchor = agents_sub[sub_idx][0]
	add_child(sub_anchor)
	sub_anchor.add_child(nav_agent)
	sub_anchor.set_meta("curr_circum", 0)
	sub_anchor.global_position = location
	nav_agent.velocity_computed.connect(
		func(safe_velocity: Vector3):
			_on_velocity_computed(safe_velocity, sub_array))
	#print(sub_array)
	#print(sub_idx)
	#print('subgroup done')
	return sub_array




## timers
func sub_timer() -> bool:
	sub_timer_count+=get_physics_process_delta_time()
	if (sub_timer_count > sub_update_time):
		sub_timer_count = 0
		return true
	return false
func check_timer() -> bool:
	check_timer_count+=get_physics_process_delta_time()
	if (check_timer_count > check_update_time):
		check_timer_count = 0
		return true
	return false
	
## creation functions
# creates a little char body
func create_char(append_target, name = "crowd") -> CharacterBody3D:
	var character = CharacterBody3D.new()
	var collision = CollisionShape3D.new()
	add_child(character)
	character.add_child(collision)
	
	
	# create for collision box
	var cap = CapsuleShape3D.new()
	cap.radius = 2.0
	cap.height = 10.0
	collision.shape = cap
	
	# create for character
	character.wall_min_slide_angle = 70.0
	character.floor_constant_speed = true
	character.floor_max_angle = 65.0
	character.safe_margin = 0.5
	character.floor_snap_length = 0.1
	character.max_slides = 2
	character.platform_on_leave = CharacterBody3D.PLATFORM_ON_LEAVE_DO_NOTHING
	character.platform_floor_layers = 0
	character.add_collision_exception_with($Anchor)
	
	# sets position of body
	#print('posit')
	var radi = circum / 4.0
	character.global_position.z = randi_range(global_position.z-radi, global_position.z+radi)
	character.global_position.x = randi_range(global_position.x-radi, global_position.x+radi)
	character.global_position.y = global_position.y + 1
	#print(character)
	#print(character.position)
	append_target.append(character)
	return character
	
	
func create_char_mesh(character, cir) -> void:
	# create for mesh
	var mesh = MeshInstance3D.new()
	character.add_child(mesh)
	var cap_mesh = CapsuleMesh.new()
	cap_mesh.radius = 2.0
	cap_mesh.height = 10.0
	mesh.mesh = cap_mesh
	
func create_char_image(character) -> void:
	var mesh = MeshInstance3D.new()
	character.add_child(mesh)
	var plane = QuadMesh.new()
	plane.size = Vector2(10, 10)
	plane.material = crowd_image
	mesh.rotation = Vector3(-90, 0, 0)
	mesh.position = Vector3(0, 10, 0)
	mesh.mesh = plane
	
	
func create_anchor_mesh(character, cir) -> void:
	var mesh = MeshInstance3D.new()
	character.add_child(mesh)
	var area = CylinderMesh.new()
	area.top_radius = cir / 2.0
	area.bottom_radius = cir / 2.0
	
	mesh.mesh = area
	mesh.transparency = 0.8
	character.add_child(mesh)
	


## signals
func _on_navigation_agent_3d_target_reached() -> void:
	state = State.IDLE

# main nav agent 
func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	#group_main(safe_velocity)
	#print("applying vel")
	pass

# relative sub nav agent
func _on_velocity_computed(safe_velocity: Vector3, sub_array) -> void:
	group_sub(sub_array, safe_velocity)
