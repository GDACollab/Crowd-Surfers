extends Area3D

@export var proximity_sound : FmodEventEmitter3D
@export var collider_scale : float = 400.
@export var one_shot: bool = false

@onready var area := self
@onready var collision_shape := $CollisionShape3D

func _ready():
	collision_shape.scale = Vector3(collider_scale, collider_scale, collider_scale)
	
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _exit_tree():
	if (proximity_sound != null):
		proximity_sound.stop()

func _on_body_entered(body):
	if body.name == "Player":
		proximity_sound.play()
		# print("Playing: " + str(proximity_sound))

func _on_body_exited(body):
	if body.name == "Player" and not one_shot:
		proximity_sound.stop()
		# print("Stopping: " + str(proximity_sound))
