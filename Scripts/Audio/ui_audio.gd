extends Node2D

## all buttons that make 'confirm' sound when clicked
@export var confirm_buttons: Array[BaseButton]
## all buttons that make 'back' sound when clicked
@export var back_buttons: Array[BaseButton]
## all buttons that make 'levelstart' sound when clicked
@export var start_buttons: Array[BaseButton]

@export var hover_buttons: Array[BaseButton]

@export var sliders: Array[Range]

func _ready() -> void:
	for button in confirm_buttons:
		button.mouse_entered.connect(play_hover_sound)
		button.focus_entered.connect(play_hover_sound)
		button.pressed.connect(play_confirm_sound)
		
	for button in start_buttons:
		button.mouse_entered.connect(play_hover_sound)
		button.focus_entered.connect(play_hover_sound)
		button.pressed.connect(play_levelstart_sound)
	
	for button in back_buttons:
		button.mouse_entered.connect(play_hover_sound)
		button.focus_entered.connect(play_hover_sound)
		button.pressed.connect(play_back_sound)
		
	for button in hover_buttons:
		button.mouse_entered.connect(play_hover_sound)
		button.focus_entered.connect(play_hover_sound)
	
	for slider in sliders:
		slider.focus_entered.connect(play_hover_sound)

func connect_confirm_button(button: BaseButton) -> void:
	confirm_buttons.append(button)
	
	button.mouse_entered.connect(play_hover_sound)
	button.focus_entered.connect(play_hover_sound)
	button.pressed.connect(play_confirm_sound)
		
func play_confirm_sound() -> void:
	FmodServer.play_one_shot("event:/SFX/UI/menu_confirm")
	
func play_levelstart_sound() -> void:
	FmodServer.play_one_shot("event:/SFX/UI/menu_levelstart")

func play_back_sound() -> void:
	$BackSound.play()

func play_hover_sound() -> void:
	$HoverSound.play()
