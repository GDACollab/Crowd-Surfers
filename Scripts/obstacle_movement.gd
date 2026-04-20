extends Node3D

## README NERDS
# Hi, Ashton here! If your car for some reason isn't moving the player with it,
# Make sure that you've changed the 'staticbody3D' to an 'animatablebody3D'
# in the prefab!
# Once you've done that, the rest of everything should work fine!

######################################
# DYNAMIC MOVEMENT STUFFS WITH AARON #
######################################

@onready var self_node = $"."

@export_range(0.0, 360.0, 1.0) var forward_direction: float = 0.0
@export_range(0.1, 10.0, 0.1) var tweenTravelSpeedRatio: float = 1.0
@export var smoothnessArr: Array[float] = []
@export var startFromSelf: bool = true # Doesnt work right now
@export var isClosed: bool = true
@export var isRotate: bool = false
@export var isVehicle : bool = true
@export var do_transparency: bool = false
#This serves to scale the velocity being applied to the player
@export var jumpVelocityRatio: float = 0.8 

## Handles the transparency for this node
@onready var transparency := Transparency.new($StaticBody3D/TopSprite, $StaticBody3D/FrontSprite)

var isMoving: bool = false
var travel_speed: float = 0.0

var follow_node: PathFollow3D
var curve: Curve3D

var myVelocity: Vector3 = Vector3.ZERO


#@export var active: bool = false:
#	set(value): 
#		active = value
		
#		# saftey check, to make sure we are in the edtior
#		if is_inside_tree() and Engine.is_editor_hint():
#			create_obstacle_path()

#@export var vList: Array[Vector2] = []: #Vertex list
#	set(new_value):
#		vList = new_value

#@export_range(1.0, 30.0, 1.0, "Tween Type") var tween_type: int = 1

func _ready() -> void:
#	if Engine.is_editor_hint():
#		active = false
	await get_tree().process_frame
	if isVehicle:
		self.add_to_group("Vehicles")
	create_obstacle_path()
	

func _process(_delta: float) -> void:
	transparency.set_do_transparency(do_transparency)

func create_obstacle_path() -> void:
	
	#if (!active) or !is_inside_tree(): return
	
	var start_pos: Vector3 = self_node.global_position
	
	var obstaclePath: Path3D = Path3D.new()
	get_parent().add_child.call_deferred(obstaclePath)
	
	var obstacleCurve: Curve3D = Curve3D.new()
	#if startFromSelf:
		#obstacleCurve.add_point(start_pos)
	
	for child in get_children():
		var cGPos = child.global_position
		obstacleCurve.add_point(Vector3(cGPos.x,start_pos.y, cGPos.z))
	
	obstacleCurve.closed = isClosed
	self.rotation = Vector3(self.rotation.x, deg_to_rad(forward_direction), self.rotation.z)
	
	for i in range(obstacleCurve.point_count):
		
		var curve_strength = smoothnessArr[i%smoothnessArr.size()]
		var point_count = obstacleCurve.point_count
		
		var prev_idx: int = (i - 1 + point_count) % point_count
		var next_idx: int = (i + 1) % point_count
		
		var prev_pos: Vector3 = obstacleCurve.get_point_position(prev_idx)
		var next_pos: Vector3 = obstacleCurve.get_point_position(next_idx)
		
		var dist_prev: float = obstacleCurve.get_point_position(i).distance_to(prev_pos)
		var dist_next: float = obstacleCurve.get_point_position(i).distance_to(next_pos)
		
		var tangent: Vector3 = (next_pos-prev_pos)
		tangent.y = 0.0
		
		if tangent.length() > 0.001: #Use a small epsilon
			tangent = tangent.normalized()
		
		var handle_in: Vector3 = -tangent * dist_prev * curve_strength
		var handle_out: Vector3 = tangent * dist_next * curve_strength
		
		obstacleCurve.set_point_in(i, handle_in)
		obstacleCurve.set_point_out(i, handle_out)
	
	obstaclePath.curve = obstacleCurve
	curve = obstacleCurve
	
	var obstaclePathFollow: PathFollow3D = PathFollow3D.new()
	obstaclePathFollow.loop = true #So that the tween doesnt encounter any issues
	obstaclePathFollow.rotation_mode = PathFollow3D.ROTATION_XYZ if isRotate else PathFollow3D.ROTATION_NONE
	obstaclePath.add_child.call_deferred(obstaclePathFollow)
	
	#self_node.reparent.call_deferred(obstaclePathFollow)
	
	follow_node = obstaclePathFollow
	#var obstaclePathLength = obstacleCurve.get_baked_length()
	travel_speed = 40.0 * tweenTravelSpeedRatio
	
	#if not startFromSelf:
		#var first_child_pos = Vector3(get_child(0).global_position.x, start_pos.y, get_child(0).global_position.z)
		#var closest_offset = obstacleCurve.get_closest_offset(first_child_pos)
		#obstaclePathFollow.progress = closest_offset
	
	isMoving = true
	#tween_movement(obstaclePathFollow, obstaclePathLength / travel_speed)

#func tween_movement(target_follow: PathFollow3D, pLen: float):
	#
	#var tween = create_tween()
	#
	#tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	#tween.set_trans(Tween.TRANS_LINEAR) #Change these however you want
	#tween.set_ease(Tween.EASE_IN_OUT) #Change these however you want
	#
	#var start_ratio: float = target_follow.progress_ratio
	#var end_ratio: float = start_ratio + 1.0
	##target_follow.progress = 10.0
	#
	#tween.tween_property(target_follow, "progress_ratio", end_ratio, pLen)
	#tween.tween_callback(func():
		#target_follow.progress_ratio = start_ratio
	#)
	#tween.set_loops() #Loops indefinitely

func _physics_process(delta: float) -> void:
	
	if !isMoving or follow_node == null: # or physicsBody == null
		return
	
	var path_length = curve.get_baked_length()
	
	follow_node.progress += travel_speed * delta
	
	if follow_node.progress >= path_length:
		follow_node.progress -= path_length
	
	"""
	Code Devs Blood Writing Left On The Castle Walls:
	ASHTON, THIS IS THE TANGENCY. TAKE IT. MAKE TITANFALL 2 LIKE WE WERE MEANT TO
	"""
	var dir = follow_node.global_position - self_node.global_position
	#var dir = curve.sample_baked_with_rotation(follow_node.progress).basis.z #Asks the forward direction at the point
	#self_node.rotation.y = atan2(dir.x, dir.z) + deg_to_rad(forward_direction)
	self_node.global_position = follow_node.global_position #For animatablebody3d
	#physicsBody.apply_central_force(apply_force()) #For RigidBody3d
	#var self_2d = Vector2(self.global_position.x, self.global_position.z)
	#var target_2d = Vector2(follow_node.global_position.x, follow_node.global_position.z)
	#var theta = self_2d.angle_to(target_2d)
	#myVelocity = Vector3(cos(theta)*100.0, 0.0, sin(theta) * 100.0)
	myVelocity = dir / delta #The distance traveled, divided by delta for average per second

func get_player_jumped_velocity() -> Vector3:
	#Calcing this every frame instead of on jump may be inefficient,
	#but it's easier overall.
	#Oh also, player velocity seems to multiply overtime,
	#So we multiply the velocity added here to balance it out.
	return myVelocity * jumpVelocityRatio
