extends Node

@onready var animatic_frames : AnimatedSprite2D = $AnimatedSprite2D
@onready var cutscene_sound : FmodEventEmitter2D = $CutsceneSound

const INPUT_DELAY := 2.

## Delay timer so the player doesn't spam through the cutscene, measured in seconds
var input_delay_timer := INPUT_DELAY 

func _ready():
	cutscene_sound.play()

func _process(delta):
	if (Input.is_action_just_pressed("DialogueInteract") and input_delay_timer < 0):
		cutscene_sound.stop()
		cutscene_sound.play()
		animatic_frames.frame += 1
		input_delay_timer = INPUT_DELAY
		
	input_delay_timer -= delta
