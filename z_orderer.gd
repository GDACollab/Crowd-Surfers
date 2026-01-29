extends Node3D

#The value that the first obsticles sprite's y-value will be set too
@export var lowered_y: float = 0.0
#Array of raycasts
@export var raycasts: Array[RayCast3D]
#Sets the raycasts length to this variable to prevent from going to infinity
@export var raycast_length: float  = 10.0
#Stores the obstacles collider and there sprite's original y-value
var stored_colliders: Dictionary = {}
#Saves what the raycasts have hit every _process
var hit_colliders: Dictionary = {}

func _ready() -> void:
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
