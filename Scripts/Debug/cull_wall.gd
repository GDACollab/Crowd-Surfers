extends Area3D
class_name CullWall

@export var cull_area : Node3D
@export var uncull_area : Node3D
var cull_children : Array[Area3D]
var uncull_children : Array[Area3D]

func _ready():
	## Finding zone Area3D's
	for c in cull_area.find_children("Area3D"):
		if c is Area3D:
			cull_children.append(c)
			c.monitorable = false
			c.monitoring = false
	for c in uncull_area.find_children("Area3D"):
		if c is Area3D:
			uncull_children.append(c)
			c.monitorable = false
			c.monitoring = false

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		print("[WALL] Culling")
		_activate()

func _activate():
	for area in uncull_children:
		if(area != null):
			area.monitoring = true
	for area in cull_children:
		if(area != null):
			area.monitoring = false
			#area.monitorable = false
