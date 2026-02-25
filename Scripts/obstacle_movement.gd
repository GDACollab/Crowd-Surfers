#@tool
extends StaticBody3D

######################################
# DYNAMIC MOVEMENT STUFFS WITH AARON #
######################################

"""
Notes on inspector:
	
	- Increase the size of the array to add more elements you can modify
	- vList consists of all the positions the staticBody3D will ease to
		- This is local position to the starting position of the node, not global
		- Remember that y values are flipped in Godot
	- sList consists of all the Smoothness values for each of the path edges between nodes
		- If the order of sList is greater than the order of vList, then some values of
		sList will simply not be used
		- If the order of sList is less than the order of vList, the smoothness will be chosen
		by the edge count % the order of sList
		- Positive values for any element in sList mean that the edge curves outward
		- 0 values for any element in sList means that there is a completely straight edge between the vertices
		- Idk exactly what negative values do but I imagine it just bulges opposite to positive values
	
"""

@onready var self_node = $"."

var follow_node: PathFollow3D
var travel_speed: float = 0.0

#@export var active: bool = false:
#	set(value): 
#		active = value
		
#		# saftey check, to make sure we are in the edtior
#		if is_inside_tree() and Engine.is_editor_hint():
#			create_obstacle_path()

#@export var vList: Array[Vector2] = []: #Vertex list
#	set(new_value):
#		vList = new_value

@export var tweenTravelTime: float = 1.0
@export var isRotate: bool = false

#@export_range(1.0, 30.0, 1.0, "Tween Type") var tween_type: int = 1

#var start_pos: Vector3 = self.position
func _ready() -> void:
#	if Engine.is_editor_hint():
#		active = false
	await get_tree().process_frame
	create_obstacle_path()

func create_obstacle_path() -> void:
	
	#if (!active) or !is_inside_tree(): return
	
	var start_pos: Vector3 = self_node.global_position
	
	var obstaclePath: Path3D = Path3D.new()
	get_parent().add_child.call_deferred(obstaclePath)
	
	var obstacleCurve: Curve3D = Curve3D.new()
	obstacleCurve.add_point(start_pos)
	
	#for i in range(vList.size()):
	#	obstacleCurve.add_point(Vector3(vList[i].x + self_node.position.x, self_node.position.y, vList[i].y + self_node.position.z))
	
	for child in get_children():
		var cGPos = child.global_position
		obstacleCurve.add_point(Vector3(cGPos.x,start_pos.y, cGPos.z))
	
	obstacleCurve.add_point(start_pos)
	
	obstacleCurve.closed = false
	
	obstacleCurve.set_point_in(0, Vector3.ZERO)
	obstacleCurve.set_point_out(0, Vector3.ZERO)
	for i in range(obstacleCurve.point_count):
		obstacleCurve.set_point_tilt(i, 0.0)
	
	obstaclePath.curve = obstacleCurve
	
	var obstaclePathFollow: PathFollow3D = PathFollow3D.new()
	obstaclePathFollow.loop = true #So that the tween doesnt encounter any issues
	obstaclePathFollow.rotation_mode = PathFollow3D.ROTATION_XYZ if isRotate else PathFollow3D.ROTATION_NONE
	obstaclePath.add_child.call_deferred(obstaclePathFollow)
	
	self_node.reparent.call_deferred(obstaclePathFollow)
	
	follow_node = obstaclePathFollow
	travel_speed = 1.0 / tweenTravelTime
	var obstaclePathLength = obstacleCurve.get_baked_length()
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	tween_movement(obstaclePathFollow, obstaclePathLength)

func tween_movement(target_follow: PathFollow3D, pLen: float):
	
	var tween = create_tween()
	
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_trans(Tween.TRANS_LINEAR) #Change these however you want
	tween.set_ease(Tween.EASE_IN_OUT) #Change these however you want
	
	#target_follow.progress = 10.0
	#
	#tween.tween_property(target_follow, "progress", pLen+0.1, tweenTravelTime)
	#tween.tween_callback(func():
		#target_follow.progress = 10.0
	#)
	#tween.set_loops() #Loops indefinitely

	target_follow.progress_ratio = 0.2
	target_follow.progress = 10.0
	
	tween.tween_property(target_follow, "progress_ratio", 1.0, tweenTravelTime)
	tween.tween_callback(func():
		target_follow.progress = 0.2
		target_follow.progress = 10.0
	)
	tween.set_loops() #Loops indefinitely

#func _process(delta: float) -> void:
	
	#print(follow_node.progress)
