extends Area3D

@export var proximity_sound_path : String
@export var collider_scale : float = 400.
@export var trigger_minimum_speed: float = 0
@export var one_shot: bool = false

@onready var area := self
@onready var collision_shape := $CollisionShape3D
@onready var persistent_key := "proximity_audio_instance_" + str(RandomNumberGenerator.new().randi())
@onready var proximity_sound : FmodEvent

func _ready():
	collision_shape.scale = Vector3(collider_scale, collider_scale, collider_scale)
	
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _exit_tree():
	if (proximity_sound != null):
		Audio.kill_persistent(persistent_key, FmodServer.FMOD_STUDIO_STOP_ALLOWFADEOUT, false)

func _on_body_entered(body):
	if body.name == "Player" and not one_shot:
		proximity_sound = Audio.create_persistent(persistent_key, proximity_sound_path, true, false)
		proximity_sound.start()
		
	elif (one_shot):
		FmodServer.play_one_shot(proximity_sound_path)

func _on_body_exited(body):
	if body.name == "Player" and not one_shot:
		Audio.kill_persistent(persistent_key, FmodServer.FMOD_STUDIO_STOP_ALLOWFADEOUT, false)
