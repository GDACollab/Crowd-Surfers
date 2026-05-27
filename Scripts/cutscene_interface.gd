extends Control

## Wait time so the player doesn't spam through the cutscene, measured in seconds
@export var WAIT_TIME := 2.
## Animation frames for animatic. If no AnimatedSprite2D is assigned, defaults to opening cutscene.
@export var animatic_frames : AnimatedSprite2D
## FMOD event for animatic. If no FmodEventEmitter2D is assigned, defaults to opening cutscene event.
@export var cutscene_sound : FmodEventEmitter2D
## Scene to transition to upon exit
@export var scene_to_transition_to := "res://Scenes/UI Menus/TitleScreen.tscn"

@onready var progress_bar : Node2D = $ProgressBar
@onready var animator = $"InterfaceAnimator"
@onready var wait_timer : float = abs(WAIT_TIME) 

var animatic_frame_count : int

func _ready():
	print("Cutscene: Cutscene has been started")
	
	if (animatic_frames == null): animatic_frames = $DefaultCutsceneFrames
	if (cutscene_sound == null): cutscene_sound = $DefaultCutsceneSound
	
	animatic_frame_count = animatic_frames.sprite_frames.get_frame_count("default")
	
	cutscene_sound.play()
	animator.play("fade_in")
	progress_bar.scale.x = 0

func _process(delta):
	if (Input.is_action_just_pressed("DialogueInteract") and wait_timer <= 0.):
		if (animatic_frames.frame + 1 >= animatic_frame_count):
			_end_cutscene()
		
		progress_bar.scale.x = 0
		
		animatic_frames.frame += 1
		wait_timer = WAIT_TIME
		cutscene_sound.set_parameter("cutscene_frame", animatic_frames.frame)
	
	if (Input.is_action_just_pressed("DialogueCancel")):
		_end_cutscene()
		
	wait_timer -= delta
	progress_bar.scale.x += delta/(WAIT_TIME + 0.1) # Divide by zero handling

func _end_cutscene():
	print("Cutscene: Cutscene has been stopped")
	cutscene_sound.stop()
	animator.play("fade_out")
	await animator.animation_finished
	SceneFadeTransition.transition_to_scene(load(scene_to_transition_to))
