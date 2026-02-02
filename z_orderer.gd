extends Node3D

#The value that the first obsticles sprite's y-value will be set too
@export var lowered_y: float = 0.0
#Array of raycasts
@export var raycasts: Array[RayCast3D]
#TODO Sets the raycasts length to this variable (Not Implemented yet)
@export var raycast_length: float  = 10.0
#Stores the obstacles collider and there sprite's original y-value
var stored_colliders: Dictionary = {}
#Saves what the raycasts have hit every _process
var hit_colliders: Dictionary = {}

func _ready() -> void:
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	check_colliders()

# Check what colliders the raycasts are hitting and add those to dictionaries
func check_colliders():
	#iterate through array of raycasts
	for raycast in raycasts:
		#makes sure the raycast is actually detecting something
		if raycast.get_collider():
			#Finds the collider and colliders shape
			var hit = hit_collider(raycast)
			var sprite = hit.get_node_or_null("Sprite3D")
			print(raycast, "Is detecting...  Collider: ", hit, " Sprite: ", sprite)
			if sprite == null:
				continue
			#Adds colliders to the 2 dictionaries with related values
			if not stored_colliders.has(hit):
				stored_colliders[hit] = sprite.position.y
			hit_colliders[hit] = true
			
			print('Dictionaries: ', stored_colliders, "   -   ", hit_colliders)
		

#Finds the collisionObject3D
func hit_collider(raycast: RayCast3D) -> CollisionShape3D:
	#Get object raycast is hitting as well as the index of the shape in the object
	var hit = raycast.get_collider()
	var shape_id = raycast.get_collider_shape()
	if hit == null or shape_id == -1:
		return null
	#Finds the node related to that index and returns the collisionshape3d were looking for
	var shape_owner = hit.shape_find_owner(shape_id)
	return hit.shape_owner_get_owner(shape_owner)
