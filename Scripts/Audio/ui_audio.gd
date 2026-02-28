extends Node2D

## all buttons that make 'confirm' sound when clicked
@export var confirm_buttons: Array[Button]
## all buttons that make 'back' sound when clicked
@export var back_buttons: Array[Button]

func _ready() -> void:
	# connect audio playback to all confirm buttons
	for button in confirm_buttons:
		button.mouse_entered.connect(play_hover_sound)
		button.pressed.connect(play_confirm_sound)
	
	# connect audio playback to all back buttons
	for button in back_buttons:
		button.mouse_entered.connect(play_hover_sound)
		button.pressed.connect(play_back_sound)

func play_confirm_sound() -> void:
	$ConfirmSound.play()

func play_back_sound() -> void:
	$BackSound.play()

func play_hover_sound() -> void:
	$HoverSound.play()
