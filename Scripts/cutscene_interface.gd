extends Control

## Wait time so the player doesn't spam through the cutscene, measured in seconds
@export var WAIT_TIME := 2.
## Animation frames for animatic. If no AnimatedSprite2D is assigned, defaults to opening cutscene.
## NOTE: if the animation name is not "default" this script breaks D:
@export var animatic_frames : AnimatedSprite2D
## FMOD event for animatic. If no FmodEventEmitter2D is assigned, defaults to opening cutscene event.
@export var cutscene_sound : FmodEventEmitter2D
## Scene to transition to upon exit
@export var scene_to_transition_to := "res://Scenes/UI Menus/TitleScreen.tscn"
## Cutscene fade-in transition time
@export var fade_in_time := 8.
## Cutscene fade-out transition time
@export var fade_out_time := 1.

@onready var animator : AnimationPlayer = $InterfaceAnimator
@onready var progress_bar : Node2D = $ProgressBar
@onready var wait_timer : float = abs(WAIT_TIME) 

var animatic_frame_count : int
var is_ending := false

func _ready():
	print("Cutscene: Cutscene has been started.")
	
	if (animatic_frames == null): 
		animatic_frames = $DefaultCutsceneFrames
		animatic_frames.visible = true
		
	if (cutscene_sound == null): 
		cutscene_sound = $DefaultCutsceneSound
	
	animatic_frame_count = animatic_frames.sprite_frames.get_frame_count("default")
	progress_bar.scale.x = 0
	
	cutscene_sound.play()
	animator.play("fade_in", -1, 1/abs(fade_in_time))

func _process(delta):
	if (Input.is_action_just_pressed("DialogueInteract") and wait_timer <= 0.):
		if (animatic_frames.frame + 1 >= animatic_frame_count):
			is_ending = true
			_end_cutscene()
		
		progress_bar.scale.x = 0
		
		animatic_frames.frame += 1
		wait_timer = WAIT_TIME
		cutscene_sound.set_parameter("cutscene_frame", animatic_frames.frame)
	
	if (Input.is_action_just_pressed("DialogueCancel")):
		_end_cutscene()
		
	if (!is_ending): 
		wait_timer -= delta
		progress_bar.scale.x += delta/(WAIT_TIME + 0.1) # Divide by zero handling

func _end_cutscene():
	print("Cutscene: Cutscene has been stopped.")
	cutscene_sound.stop()
	animator.play("fade_out", -1, 1/abs(fade_out_time))
	await get_tree().create_timer(1/abs(fade_out_time)).timeout
	SceneFadeTransition.transition_to_scene(load(scene_to_transition_to))
