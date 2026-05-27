extends Control

## Wait time so the player doesn't spam through the cutscene, measured in seconds
@export var WAIT_TIME := 2.
## Animation frames for animatic. If no AnimatedSprite2D is assigned, defaults to opening cutscene.
@export var animatic_frames : AnimatedSprite2D
## FMOD event for animatic. If no FmodEventEmitter2D is assigned, defaults to opening cutscene event.
@export var cutscene_sound : FmodEventEmitter2D

@onready var progress_bar : Node2D = $ProgressBar
@onready var wait_timer : float = abs(WAIT_TIME) 

var animatic_frame_count : int

func _ready():
	if (animatic_frames == null): animatic_frames = $DefaultCutsceneFrames
	if (cutscene_sound == null): cutscene_sound = $DefaultCutsceneSound
	
	animatic_frame_count = animatic_frames.sprite_frames.get_frame_count("default")
	
	cutscene_sound.play()
	progress_bar.scale.x = 0

func _process(delta):
	if (Input.is_action_just_pressed("DialogueInteract") and wait_timer <= 0.):
		if (animatic_frames.frame + 1 >= animatic_frame_count):
			_end_cutscene()
		
		progress_bar.scale.x = 0
		cutscene_sound.stop()
		
		animatic_frames.frame += 1
		wait_timer = WAIT_TIME
		cutscene_sound.set_parameter("cutscene_frame", animatic_frames.frame)
		cutscene_sound.play()
	
	if (Input.is_action_just_pressed("DialogueCancel")):
		_end_cutscene()
		
	wait_timer -= delta
	progress_bar.scale.x += delta/(WAIT_TIME + 0.1) # Divide by zero handling

func _end_cutscene():
	## TODO: Scene flow
	print("trigger")
	pass
