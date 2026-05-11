extends Node3D

## I MADE MISTAKE, CIRCUMFERENCE MEANS DIAMETER

# EXPORT VARIABLES
@export var debug: bool = false
@export var circum: float = 10.0 # area of main brain
@export var ratio_circum: float = 0.7 # area ratio of subgroups max, and max find distance
@export var merge_ratio: float = 0.75 # default is my pref, increase distance beyond 2.0 exceeds circum, I do not recommend. Decreasing makes the distance less than the radius.
@export var crowd_size: int = 1.0
@export var max_speed: float = 20.0
@export var acceleration: float = 20.0
@export var height_recalc_sensitivity: float = 10.0 # this is amount of difference in height lost before recalculating
@export var check_limit: int = 4
@export var check_running_distance = 750

# CONSTANTS
const CAP_RADIUS = 4
const CAP_HEIGHT = 16
const HEIGHT_RESET = -50
const ε: float = 0.1

# VARIABLES RIDS
var visual_scale = 1.0
var crowd_basis = Basis.IDENTITY.scaled(Vector3(visual_scale, visual_scale, visual_scale))
var check_rate: int = 2
var check_freq: int = 0

# ARRAY
var agents_main: Array = []
var agents_sub: Array = []
var deletion_queue: Array = []
var call_queue: Array = []
var rid_dictionary = {}
var agents: Array = []

# STATES
enum State { IDLE, WAIT, MOVE, DISPERSE }
var state : State = State.IDLE

# TIMER
var check_update_time: float = 2.0
var check_timer_count: float = 0.0

var sub_update_time: float = 3.0
var sub_timer_count: float = 2.0

# ANCHOR VARIABLES
var anchor_velocity = Vector3(0, 0, 0)

# INTERNAL VARIABLES
var radius: float
var gravity_force_for_velocity = Vector3.ZERO
#var angle_radians = atan2(CAP_HEIGHT, CAP_RADIUS)
#var angle_degrees = rad_to_deg(angle_radians)

# TARGETS
var curr_point = 0
@export var route: Array[Vector3] = [
	Vector3(0,0,0),
	]

# NODE REFERENCE
@onready var navigation_agent_3d: NavigationAgent3D = $Anchor/NavigationAgent3D
@onready var anchor: Node3D = $Anchor
@onready var player_reference: CharacterBody3D = get_tree().root.find_child("Player", true, false)
@onready var nav_map = get_world_3d().navigation_map
var multi_mesh_manager: MultiMeshInstance3D

# SCENE/PREFAB REFERENCES
@onready var anchor_type = preload("res://Scenes/Level Components/Crowds/sub-anchor.tscn")
@onready var crowd = preload("res://Assets/Art/temp player.png")

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
	check_rate = crowd_size / check_limit
	radius = circum / 2.0
	area.top_radius = radius
	area.bottom_radius = radius
	
	anchor_mesh.mesh = area
	# Transparency temporary debug
	if (!debug):
		anchor_mesh.transparency = 1.0
		anchor_mesh.cast_shadow = false
	
	agents_main.append(anchor)
	anchor.add_collision_exception_with(player_reference)
	
	gravity_force_for_velocity = ProjectSettings.get_setting("physics/3d/default_gravity_vector")*10
	
	group_brain(crowd_size, circum, 1)
	#group_brain(1, circum, 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if (!checkShouldRunInstance()): return
	print('running')
	# move behaviors
	match state: 
		State.IDLE:
			get_new_loc()
			apply_move_and_slide(anchor)
			for nav in agents_sub:
				apply_move_and_slide(nav[0])
				get_new_sub_loc(nav[0].find_child("NavigationAgent3D", false), nav[0])
		State.MOVE:
			group_main(moving_behav(anchor, navigation_agent_3d))
			apply_move_and_slide(anchor)
			for nav in agents_sub:
				var nav_agent = nav[0].find_child("NavigationAgent3D", false)
				
				group_sub(nav, moving_behav(nav[0], nav_agent))
				apply_move_and_slide(nav[0])
				
	# this call is for mass swaps
	for c in call_queue:
		if c.is_valid():
			c.call()
	call_queue.clear()
	delete_queue()
	
	sub_timer()
	checkMemberAmor()
	
	# call all swaps (maybe do this before find instead of swap)
	for c in call_queue:
		if c.is_valid():
			c.call()
	call_queue.clear()
	# deletion for all in queue
	delete_queue()
	
	# progress check freq
	check_freq += check_limit
	check_freq = check_freq % crowd_size
	
# mutli_mesh_process
# physics appliance for multi mesh experiment
func multi_mesh_process(array, vel) -> void:
	for member_idx in range(array.size()-1,0,-1):
		var member = array[member_idx]
		var member_transform = PhysicsServer3D.body_get_state(member, PhysicsServer3D.BODY_STATE_TRANSFORM)
		member_transform = member_transform.scaled(Vector3(visual_scale, visual_scale, visual_scale))
		var current_vel = PhysicsServer3D.body_get_state(member, PhysicsServer3D.BODY_STATE_LINEAR_VELOCITY)
		var mesh_index = rid_dictionary[member].rid_to_mesh_index
		
		#if (current_vel.length() >= max_speed):
			
		if (!rid_dictionary[member].stomped):
			var velocity_change = (vel - current_vel)
				
			PhysicsServer3D.body_apply_central_force(member, velocity_change * acceleration)
			multi_mesh_manager.multimesh.set_instance_transform(mesh_index, member_transform)
		else:
			multi_mesh_manager.multimesh.set_instance_transform(mesh_index, member_transform)
		
		
# group brain
# Creates the groups, will need to send a list of what needs to be being checked
# Parameters: 
# - list of individuals
# - size circum
# - either point list which is static, or dynamic point? Most likely, we can find some balance
# - (best solution to the above) toggle for group main or sub
# Return: maybe the list of indivs
func group_brain(count, size, type = 1, position = Vector3(0,0,0) ) -> Array:
	if (type == 1):
		multi_mesh_creation()
		create_rids(global_position)
		pass
		for i in range(count):
			pass
		
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
	var delta_time = get_physics_process_delta_time()
	var accel_delta = delta_time * acceleration;
	var vel = anchor.velocity.move_toward(safe_velocity, accel_delta)

	anchor.velocity.x = lerp(anchor.velocity.x, vel.x, accel_delta)
	anchor.velocity.z = lerp(anchor.velocity.z, vel.z, accel_delta)
	anchor.velocity.y +=  gravity_force_for_velocity.y * delta_time
	# call its members
	multi_mesh_process(agents_main, vel)

# sub brain
# Sub loop for remerging, what needs to be initially made and what to follow? (might need to split up again)
# Parameters:
# - Sub_index: reference to where sub brain is placed in array
# - Safe_velocity: Velocity to apply to the agents
func group_sub(sub_array, safe_velocity) -> void:
	if (sub_array.is_empty()): return
	
	var sub_anchor = sub_array[0]
	var delta_time = get_physics_process_delta_time()
	var accel_delta = delta_time * acceleration * 1.5;
	var vel = sub_anchor.velocity.move_toward(safe_velocity, accel_delta)
	
	sub_anchor.velocity.x = lerp(sub_anchor.velocity.x, vel.x, accel_delta)
	sub_anchor.velocity.z = lerp(sub_anchor.velocity.z, vel.z, accel_delta)
	sub_anchor.velocity.y +=  gravity_force_for_velocity.y * delta_time
	
	checkSubAmor(sub_array, vel)
	multi_mesh_process(sub_array, vel)
	

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
		
	elif target is RID:
		print("crowd, may involve either slide or none?")
		bounce_behav(target, collision)
		bounce_behav(source, collision)
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
		checkCollision(member, target, collision)
		
		#if (local_hit.z < -0.1 or local_hit.x > 0.1 or local_hit.x < -0.1):
			#if (member.global_position.distance_squared_to(anchor.global_position) >= circum): 
				#find_group_behav(member, origin, 0)
# checkMemberAmor
# Checks the given array, through amortization. Searches for missing from the main group, or if it is near the main group
# convert to multi functions
func checkMemberAmor() -> void:
	# will never be 0 (good for anchor)
	var curr_relative_index = (check_freq)
	
	# check through member in given freq, to see if member is outside of given group or at anchor
	for i in range(check_limit):
		var check_index = (curr_relative_index + i) % crowd_size
		var array = rid_dictionary[agents[check_index]].group_reference
		var non_main = !(array == agents_main)
		var member = agents[check_index]
		#if (not is_instance_valid(array[0]) and check_index != 0): return
		var temp_position = get_rid_position(member) # replaceemnt to get global position of a rid
		var member_position = Vector2(temp_position.x, temp_position.z)
		#if array == null or array.is_empty(): 
			#continue
		var ratio = (ratio_circum if non_main else 1.0) # ratio circum if nonmain
		if (member.is_valid() and member_position.distance_to(Vector2(array[0].global_position.x, array[0].global_position.z)) >= circum / 2.0 * ratio):
			find_group_behav(member, array, 0)
			continue
		
		elif (member.is_valid() and non_main and member_position.distance_to(Vector2(anchor.global_position.x, anchor.global_position.z)) < circum / 2.0):
			call_queue.append(Callable(self, "swap_member_behav").bind(array, member, agents_main))
			continue
	
# checkSubAmor
# Checks the given array with every sub anchor to see for potential mass swap
# convert to multi functions
func checkSubAmor(array, non_main) -> void:
	# returns if main anchor, since main anchor should not merge
	if (!non_main or agents_sub.size() <= 0): return
	var curr_check_rate = floor(array.size() / check_limit)
	var curr_relative_index = (curr_check_rate + check_freq)
	# check through each sub anchor to see if the sub groups can merge
	for i in range(check_limit):
		var check_index = (curr_relative_index + i) % agents_sub.size()
		var sub_group = agents_sub[check_index]
		
		if not is_instance_valid(array[0]): return
		var given_anchor_position = Vector2(array[0].global_position.x, array[0].global_position.z)
		#print('sub_anc')
		#print(given_anchor_position.distance_to(Vector2(sub_group[0].global_position.x, sub_group[0].global_position.z)))
		if (array.size() < sub_group.size() and given_anchor_position.distance_to(Vector2(sub_group[0].global_position.x, sub_group[0].global_position.z)) < circum / 3.0):
			#print('working anchor given')
			call_queue.append(Callable(self, "mass_swap_behav").bind(array, sub_group))
			return
	
	
# checkMerge
func checkMerge(member, array) -> void: 
	if (get_rid_position(member).distance_to(anchor.global_position) < circum):
		call_queue.append(Callable(self, "swap_member_behav").bind(array, member, agents_main))
		
	else:
		for sub_array in agents_sub:
			if (get_rid_position(member).distance_to(sub_array[0].global_position) < circum):
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
		
# checkReset
# Checks the Y position, if the crowd member is falling out of the map, it will bring them back to the main anchor
func checkReset(rid) -> void:
	if !(get_rid_position(rid).y < HEIGHT_RESET): return
	var member_transform = Transform3D(crowd_basis, anchor.global_position)
		
	PhysicsServer3D.body_set_state(rid, PhysicsServer3D.BODY_STATE_TRANSFORM, member_transform)
	multi_mesh_manager.multimesh.set_instance_transform(rid_dictionary[rid].rid_to_mesh_index, member_transform)

# checkShouldRunInstance
# Checks if the physics process for the current crowds should be running
# NOTE Probably a better way to do this then how I am doing
func checkShouldRunInstance() -> bool:
	for point in route:
		var point_position = Vector2(point.x, point.z)
		var player_position = Vector2(player_reference.global_position.x, player_reference.global_position.z)
		
		var current_distance = player_position.distance_to(point_position)
		if current_distance < check_running_distance:
			return true
	return false

# finds a new location for nav agent with a given point to point system
# Bug:
# - Currently, it will need to recalculate the path if it is underneath the current height, since often times it doesn't recalculate when it needs to
func get_new_loc() -> void:
	if (navigation_agent_3d.is_target_reached()): curr_point += 1
	if (curr_point > route.size()-1): curr_point = 0
	
	navigation_agent_3d.target_position = NavigationServer3D.map_get_closest_point(nav_map, route[curr_point])
	
	if (navigation_agent_3d.target_position != Vector3.ZERO and state != State.MOVE): state = State.MOVE


# simplier nav locator for sub groups
func get_new_sub_loc(given_agent, nav) -> void:
	var new_pos = anchor.global_position
	if nav.global_position.distance_to(new_pos) < 2.0: return
	given_agent.target_position = NavigationServer3D.map_get_closest_point(nav_map, anchor.global_position)
	

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
	for agt_array in agents_sub:
		var dist = get_rid_position(member).distance_to(agt_array[0].global_position)
		var temp_circum = radius * ratio_circum
		# check if objectect is close and combining doesn't exceed limit
		if (dist <= temp_circum):
			call_queue.append(Callable(self, "swap_member_behav").bind(origin, member, agt_array))
			return
	var new_sub = group_brain(0, 0, 0, get_rid_position(member))
	call_queue.append(Callable(self, "swap_member_behav").bind(origin, member, new_sub))

# delete_group_behav
# Deletes the a group, only call when it either merging with sub group or main group
func delete_group_behav(target) -> void:
	if (target == agents_main or target.size() > 1): return
	
	if target.is_empty():
		agents_sub.erase(target)
		return
	
	var nav_agent = target[0]
	var nav_node = nav_agent.find_child("NavigationAgent3D", false)
	if (is_instance_valid(nav_node) and nav_node.velocity_computed.is_connected(_on_velocity_computed)):
		nav_node.velocity_computed.disconnect(_on_velocity_computed)
	if (is_instance_valid(nav_agent)):
		nav_agent.queue_free()
	
	agents_sub.erase(target)
	#print('delete group')
	
# delete_queue
# Goes through the queue to call deletion on groups
func delete_queue() -> void:
	for del in deletion_queue:
		delete_group_behav(del)
	deletion_queue.clear()

# remove_member_behav
# Removes a member 
func remove_member_behav(member, target) -> void:
	var temp_idx = target.find(member)
	target.remove_at(temp_idx)
	#print('remove')

# add_member_behav
# Adds a member
func add_member_behav(member, target) -> void:
	target.append(member)
	#print('add')

# swap_member_behav
# Swaps a member with another group, essentially remove and adding, and possibly deleting if none exist
func swap_member_behav(source, member, target) -> void:
	if (!member or !source): return

	remove_member_behav(member, source)
	add_member_behav(member, target)
	
	rid_dictionary[member].group_reference = target
	if (source.size() == 1 and source != agents_main): 
		deletion_queue.append(source)
	
# mass_swap_behav
# Swaps massive group, calling the swap member, but does so without needing to store tons of function calls
func mass_swap_behav(array, target) -> void:
	if (!array or !target): return
	
	# only swap if the member is in range of target's cirucm
	var target_anchor = Vector2(target[0].global_position.x, target[0].global_position.z)
	for member_idx in range(array.size() -1, 0, -1):
		var member = array[member_idx]
		var member_pos = get_rid_position(member)
		if (target_anchor.distance_to(Vector2(member_pos.x, member_pos.z)) < (circum / 2.0) * ratio_circum * merge_ratio):
			swap_member_behav(array, member, target)
	
	# reposition the current anchor to the last unswapped member if it exists
	return
	if (target.size() > 1):
		target[0].global_position = get_rid_position(target[1])
		#var current_vel = PhysicsServer3D.body_get_state(target[1], PhysicsServer3D.BODY_STATE_LINEAR_VELOCITY)
		#set_velocity(target[0], current_vel) # might not be needed


# creats a sub group array with an anchor
func create_sub_group(location, sub_idx = 0) -> Array:
	var sub_array = []
	create_anchor(sub_array, circum * ratio_circum)
	agents_sub.insert(sub_idx, sub_array)
	var sub_anchor = agents_sub[sub_idx][0]
	sub_anchor.add_collision_exception_with(player_reference)
	sub_anchor.global_position = location
	#nav_agent.velocity_computed.connect(
		#func(safe_velocity: Vector3):
			#_on_velocity_computed(safe_velocity, sub_array))

	var nav_agent = sub_anchor.find_child("NavigationAgent3D", false)
	assert(nav_agent != null, "Error: NavigationAgent3D not found on sub_anchor!")
	nav_agent.max_speed = max_speed * 1.5
	nav_agent.radius = 4.0
	nav_agent.navigation_finished.connect(Callable(self, "_on_navigation_finished").bind(nav_agent, sub_anchor))
	get_new_sub_loc(nav_agent, sub_anchor)
	return sub_array




## timers
func sub_timer() -> void:
	sub_timer_count+=get_physics_process_delta_time()
	if (sub_timer_count >= sub_update_time):
		sub_timer_count = 0
		sub_reset()

func sub_reset() -> void:
	get_new_loc()
	for nav in agents_sub:
		var nav_agent = nav[0].find_child("NavigationAgent3D", false)
		get_new_sub_loc(nav_agent, nav[0])

func check_timer() -> bool:
	check_timer_count+=get_physics_process_delta_time()
	if (check_timer_count > check_update_time):
		check_timer_count = 0
		return true
	return false
	
	
func create_char_mesh(character, cir) -> void:
	# create for mesh
	var mesh = MeshInstance3D.new()
	character.add_child(mesh)
	var cap_mesh = CapsuleMesh.new()
	cap_mesh.radius = CAP_RADIUS
	cap_mesh.height = CAP_HEIGHT
	mesh.mesh = cap_mesh

func multi_mesh_creation() -> void:
	var multi_mesh_instant = MultiMeshInstance3D.new()
	var multi_mesh = MultiMesh.new()
	multi_mesh.transform_format = MultiMesh.TRANSFORM_3D
	
	var q_mesh = QuadMesh.new()
	q_mesh.size = Vector2(16, 16)
	multi_mesh.mesh = q_mesh
	multi_mesh.use_colors = true
	var mat = StandardMaterial3D.new()
	mat.albedo_texture = crowd
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.vertex_color_use_as_albedo = true
	mat.albedo_color = Color.WHITE
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mat.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_OPAQUE_ONLY
	q_mesh.material = mat
	
	multi_mesh.instance_count = crowd_size
	multi_mesh.visible_instance_count = -1
	
	multi_mesh_instant.multimesh = multi_mesh
	multi_mesh_instant.top_level = true # Ignore parent transforms
	add_child(multi_mesh_instant)
	
	#multi_mesh_instant.multimesh.custom_aabb = AABB(Vector3(-5000, -500, -5000), Vector3(10000, 1000, 10000))
	multi_mesh_manager = multi_mesh_instant


func create_rids(position) -> void:
	var city_colors = [
	Color(0.6, 0.6, 0.6),  # light gray
	Color(0.3, 0.3, 0.3),  # dark gray
	Color(0.4, 0.5, 0.6),  # muted blue
	Color(0.4, 0.3, 0.2),  # dull brown
	Color(0.3, 0.35, 0.25) # olive/tan green
]

	var hexPackedPositions = getHexagonalPackedPositions(crowd_size, circum / 2.0, position)
	
	#print("Crowd Size: " + str(crowd_size))
	#print("Position: " + str(position))a
	#print("Container Radius: " + str(circum / 2.0))
	#print("Hexagonal Packed Position Array: " + str(hexPackedPositions))
	
	for i in multi_mesh_manager.multimesh.instance_count:
		var rid = PhysicsServer3D.body_create()
		PhysicsServer3D.body_set_mode(rid, PhysicsServer3D.BODY_MODE_RIGID)
		PhysicsServer3D.body_set_space(rid, get_world_3d().space)
		
		var shape = PhysicsServer3D.capsule_shape_create() # I'm not too sure on this
		PhysicsServer3D.shape_set_data(shape, {"radius": CAP_RADIUS, "height": CAP_HEIGHT})
		PhysicsServer3D.body_add_shape(rid, shape)
		
		var radi = circum / 4.0
		var start_pos = hexPackedPositions[i] if i < hexPackedPositions.size() else position
		#var start_transform = Transform3D(crowd_basis, Vector3(position.x + randf_range(-radi, radi), position.y, position.z + randf_range(-radi, radi)))
		var start_transform = Transform3D(crowd_basis, start_pos) if start_pos != position else Transform3D(crowd_basis, Vector3(position.x + randf_range(-radi, radi), position.y, position.z + randf_range(-radi, radi)))
		
		PhysicsServer3D.body_set_state(rid, PhysicsServer3D.BODY_STATE_TRANSFORM, start_transform)
		multi_mesh_manager.multimesh.set_instance_transform(i, start_transform)
		multi_mesh_manager.multimesh.set_instance_color(i, city_colors[randi() % city_colors.size()])
		
		# physics lock
		var mass = 1.0
		PhysicsServer3D.body_set_axis_lock(rid, PhysicsServer3D.BODY_AXIS_ANGULAR_X, true)
		PhysicsServer3D.body_set_axis_lock(rid, PhysicsServer3D.BODY_AXIS_ANGULAR_Z, true)
		PhysicsServer3D.body_set_axis_lock(rid, PhysicsServer3D.BODY_AXIS_ANGULAR_Y, true)
		PhysicsServer3D.body_set_param(rid, PhysicsServer3D.BODY_PARAM_GRAVITY_SCALE, 50.0)
		PhysicsServer3D.body_set_param(rid, PhysicsServer3D.BODY_PARAM_MASS, mass)
		PhysicsServer3D.body_set_param(rid, PhysicsServer3D.BODY_PARAM_FRICTION, 0.0)
		
		# script reference attachment
		PhysicsServer3D.body_attach_object_instance_id(rid, get_instance_id())
		# layer and masks
		var layer_3 = 4 # (2 to the power of 2) I have no idea why they are like this other than binary
		var mask_1_and_3 = 1 + 4 # (1 + 4 = 5)
		PhysicsServer3D.body_set_collision_layer(rid, layer_3)
		PhysicsServer3D.body_set_collision_mask(rid, mask_1_and_3)
		
		# assign rid for reference
		rid_dictionary[rid] = CrowdData.new(i, agents_main)
		agents.append(rid)
		
		
		# Add to main group and map to the visual instance ID
		agents_main.append(rid)

func getHexagonalPackedPositions(agtCount: int, spawnRad: float, spawnPos: Vector3) -> Array:
	
	var positions: Array = []
	
	const LAYER_MAX: int = 50
	var physicsMask = 1
	
	var R = CAP_RADIUS + ε/2
	var dx = 2.0 * R
	var dz = sqrt(3.0) * R
	
	var maxCols = int((spawnRad * 2.0) / dx)
	
	var gridOrigin = Vector2(spawnPos.x - spawnRad, spawnPos.z - spawnRad) + Vector2(R, R)
	var center2D = Vector2(spawnPos.x, spawnPos.z)
	var physicsState = get_world_3d().direct_space_state
	
	var placedCount = 0
	var row = 0
	var layer = 0
	
	#const NAV_SNAP_TOLERANCE: float = CAP_RADIUS
	
	while placedCount < agtCount:
		
		#print("Layer: " + str(layer))
		
		if layer >= LAYER_MAX:
			break
		
		var shiftX = R * (row%2)
		
		for col in range(maxCols):
			
			if placedCount >= agtCount:
				break
			
			var x = gridOrigin.x + shiftX + dx * col
			var z = gridOrigin.y + dz * row
			
			var candidatePos = Vector2(x, z)
			
			# Check if the XZ projection of the agent resides within the container
			if( !Geometry2D.is_point_in_circle(candidatePos, center2D, spawnRad - CAP_RADIUS) ):
				continue
			
			var y = spawnPos.y + (CAP_HEIGHT + ε) * layer
			var candidate3D = Vector3(candidatePos.x, y, candidatePos.y)
			
			# Create a specialized physics raycast to check if the crowd member would intersect in physical space
			var query = PhysicsShapeQueryParameters3D.new()
			query.shape = SphereShape3D.new()
			query.shape.radius = CAP_RADIUS + ε
			query.transform = Transform3D(Basis.IDENTITY, candidate3D)
			query.collision_mask = physicsMask
			if !physicsState.intersect_shape(query, physicsMask).is_empty():
				continue # Skip to next instance
			
			positions.append(candidate3D)
			placedCount += 1
			
		row += 1
		
		if dz * row > spawnRad * 2.0 + dz:
			row = 0
			layer += 1
	
	#print("In Function Positions: " + str(positions))
	return positions


# apply a force from a center to a body
func crowd_stomp_spread(source, rid, force, stomp_radius) -> void:
	PhysicsServer3D.body_set_state(rid, PhysicsServer3D.BODY_STATE_SLEEPING, false)
	rid_dictionary[rid].stomped = true # set the crowd to use physics for stomp
	
	var source_pos = source.global_position
	var rid_pos = get_rid_position(rid)
	
	# apply ratio of force
	const MIN_RATIO = 0.1
	const MAX_RATIO = 1.0
	const GAP_RADIUS = 1.0
	var dist = Vector2(source_pos.x, source_pos.z).distance_to(Vector2(rid_pos.x, rid_pos.z))
	var ratio = remap(dist, GAP_RADIUS, stomp_radius, MAX_RATIO, MIN_RATIO)
	#var ratio = clamp(1.0 - (Vector2(source_pos.x, source_pos.z).distance_to(Vector2(rid_pos.x, rid_pos.z)) / stomp_radius), min_ratio, max_ratio)
	ratio = clamp(ratio, 0.0, 1.0)
	ratio = pow(ratio, 2)
	var force_vec = -(source_pos - rid_pos) * force * ratio
	
	PhysicsServer3D.body_apply_central_impulse(rid, force_vec) # might need to multiply by time

# tells the crowd to reapply its normal force and movement physics, based off the given array of rids
func crowd_stomp_stop(rid) -> void:
	rid_dictionary[rid].stomped = false # set the crowd to use physics for stomp

# get rid position from reference
func get_rid_position(rid) -> Vector3:
		var current_trans = PhysicsServer3D.body_get_state(rid, PhysicsServer3D.BODY_STATE_TRANSFORM)
		current_trans = current_trans.scaled(Vector3(visual_scale, visual_scale, visual_scale))
		var current_pos = current_trans.origin
		return current_pos
		
# set velocity of a character body 3d, may make it apply to rids too
func set_velocity(body, vel) -> void:
	body.velocity.x = vel.x
	body.velocity.z = vel.z
	body.velocity.y += gravity_force_for_velocity.y * get_physics_process_delta_time()
	
# get a force with given direction/velocity (I think) over time
func get_velocity_change(member, target_vel) -> Vector3:
	var current_vel = PhysicsServer3D.body_get_state(member, PhysicsServer3D.BODY_STATE_LINEAR_VELOCITY)
	var velocity_change = (target_vel - current_vel)
	return velocity_change
	

# set the velocity of the member to target_vel over time
func set_velocity_change(member, target_vel: Vector3) -> void:
	var member_transform = PhysicsServer3D.body_get_state(member, PhysicsServer3D.BODY_STATE_TRANSFORM)
	member_transform = member_transform.scaled(Vector3(visual_scale, visual_scale, visual_scale))
	PhysicsServer3D.body_apply_central_force(member, get_velocity_change(member, target_vel) * acceleration)
	var mesh_index = rid_dictionary[member].rid_to_mesh_index
	multi_mesh_manager.multimesh.set_instance_transform(mesh_index, member_transform)

func create_anchor(append_target, cir) -> void:
	var sub_anchor = anchor_type.instantiate()
	add_child(sub_anchor)
	var mesh_instant = sub_anchor.find_child("MeshInstance3D", false)
	var mesh = mesh_instant.mesh
	mesh.top_radius = cir / 2.0
	mesh.bottom_radius = cir / 2.0
	
	if (!debug):
		mesh_instant.transparency = 1.0
		mesh_instant.cast_shadow = false
	else:
		mesh_instant.transparency = 0.9
		
	append_target.append(sub_anchor)
	


## signals
func _on_navigation_agent_3d_target_reached() -> void:
	state = State.IDLE

# relative sub nav agent
func _on_velocity_computed(safe_velocity: Vector3, sub_array) -> void:
	group_sub(sub_array, safe_velocity)


func _on_navigation_agent_3d_waypoint_reached(details: Dictionary) -> void:
	pass # Replace with function body.
	



func _on_navigation_agent_3d_navigation_finished() -> void:
	get_new_loc()

func _on_navigation_finished(sub_nav: NavigationAgent3D, sub_anchor: CharacterBody3D) -> void:
	get_new_sub_loc(sub_nav, sub_anchor)
	
	
func apply_move_and_slide(member) -> void:
	member.move_and_slide()

# free all rids before leaving scene 
func _on_screen_exited():
	for rid in agents:
		PhysicsServer3D.free_rid(rid)
