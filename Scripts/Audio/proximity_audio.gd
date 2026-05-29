extends Area3D

@export var proximity_sound_emitter : FmodEventEmitter3D
@export var collider_scale : float = 400.
@export var trigger_minimum_speed: float = 0
@export var one_shot: bool = false

@onready var area := self
@onready var collision_shape := $CollisionShape3D
@onready var persistent_key := "proximity_audio_instance_" + str(RandomNumberGenerator.new().randi())

func _ready():
	collision_shape.scale = Vector3(collider_scale, collider_scale, collider_scale)
	
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if (proximity_sound_emitter != null):
		if body.name == "Player" and not one_shot:
			proximity_sound_emitter.play()
			# print("Creating new " + str(proximity_sound) + " instance")
			
		elif (one_shot):
			proximity_sound_emitter.play_one_shot()

func _on_body_exited(body):
	if (proximity_sound_emitter != null and body.name == "Player" and not one_shot):
		proximity_sound_emitter.stop()
		# print("Killing " + proximity_sound_path + " instance")
