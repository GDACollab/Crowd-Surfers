class_name DialogueInterface
extends Control

@export var mainPanels : Array[InterfacePanel]
@export_category("Panel Settings")
## Dialogue Panel prefab
@export var dialoguePanel : PackedScene
@export var right_panel_sprite : Texture2D
## Type of transition for all tweens
@export var transitionType : Tween.TransitionType = Tween.TransitionType.TRANS_ELASTIC
@export var easeType : Tween.EaseType = Tween.EaseType.EASE_IN_OUT
@export_category("Choices")
## Choice Button prefab
@export var choiceButton : PackedScene
@export var choice_button_sprites : Array[Texture2D]
## Amount of time the player must wait before selecing a choice
@export var choiceSelectDelay : float
@export_category("Portrait Settings")
@export var defaultPortait : Texture2D
@export var speakingPortraitScale := Vector2(1.25, 1.25)
@export var previousSpeakerColor := Color.DIM_GRAY
## Where the portrait moves when swapping characters
@export var portraitSwapPosition := Vector2(2000, 345)
@export var portraitSwapTime := 1.0
@export_category("Past Dialogue Line Settings")
@export var upperDialogueBoxHeight : float = 0
@export var upperDialogueBoxScale := Vector2(0.5, 0.5)
@export var lowerDialogueBoxHeight : float = 200
@export var lowerDialogueBoxScale := Vector2(0.75, 0.75)
@export var portraitOutlineMaterial : Material
@export var outlineSize : int = 5
## Determines if shader drawing varies in size
@export var sketchyDraw := true
@export var textSpeedScale : float = 1
@onready var leftPortrait = $"Left Character Portrait/Portrait Image"
@onready var rightPortrait = $"Right Character Portrait/Portrait Image"
var textSpeedInMilliseconds : float = 0.05
@onready var animator = $"Interface Animator"
var dialoguePanels : Array[InterfacePanel]
var dialogueLabel : Label
var currentStory : InkStory
var currentChoiceIndex := 0
var isTyping := false
var dialogueText := ""
var choiceButtons : Array[Control]
var selectedButton : DialogueChoiceButton
var choicesDisplayed := false
var slipSpoke := false ##If true, last dialogue box goes left
var currentSpeakerData : CharacterDialogueData
var currentSpeaker : Control
var previousSpeakerTag : String
var previousSpeaker : Control
var lastNonSlipSpeaker : String = ""
var awaitingAnimations := false
var awaitingTags := false
var currentVOPath : String = ""
var hub_music: FmodEvent
var music_bus : FmodBus
var music_bus_volume_scalar := 0.25

func _ready() -> void:	
	currentStory = Inky.GetCurrentStory()
	$"Left Character Portrait".find_child("Portrait Image").texture = defaultPortait
	_load_main_panels()
	_get_input()
	music_bus = FmodServer.get_bus("bus:/MUS")
	music_bus.volume *= music_bus_volume_scalar
	
	# Start music
	if (!Audio.registry.has("mus_hub")):
		hub_music = Audio.create_persistent("mus_hub", "event:/MUS/hub")
		hub_music.start()
		
	else:
		Audio.unpause_persistent("mus_hub")
		
func _exit_tree() -> void:
	music_bus.volume /= music_bus_volume_scalar
	Audio.kill_persistent("mus_hub")

func _process(_delta: float) -> void:
	if(Input.is_action_just_pressed("DialogueCancel")):
		Inky.EndDialogue()
	if(Input.is_action_just_pressed("DialogueInteract")):
		if(!isTyping):
			if(!awaitingAnimations): 
				FmodServer.play_one_shot("event:/SFX/UI/dialogue_next")
				
			_get_input()
		else:
			_skip_scroll()
			
	# Choice selection
	if(choicesDisplayed):
		if(Input.is_action_just_pressed("move_down")):
			selectedButton._unhighlight()
			if(currentChoiceIndex < currentStory.GetCurrentChoices().size() - 1):
				currentChoiceIndex += 1
			else:
				currentChoiceIndex = 0
			selectedButton = _find_choice(currentChoiceIndex)
			selectedButton._highlight()
		if(Input.is_action_just_pressed("move_up")):
			selectedButton._unhighlight()
			if(currentChoiceIndex > 0):
				currentChoiceIndex -= 1
			else:
				currentChoiceIndex = currentStory.GetCurrentChoices().size() - 1
			selectedButton = _find_choice(currentChoiceIndex)
			selectedButton._highlight()

func _get_input():
	if(!awaitingAnimations):
		# Continue story
		if(currentStory.GetCanContinue()):
			_continue_story()
		# Display choices
		elif(currentStory.GetCurrentChoices().size() > 0 and !choicesDisplayed):
			_display_choices()
		# Make choice
		elif(currentStory.GetCurrentChoices().size() > 0 and choicesDisplayed):
			currentStory.ChooseChoiceIndex(currentChoiceIndex)
			_clear_choices()
			_continue_story()
		# End story
		else:
			Inky.EndDialogue()

##  Loads next line
func _continue_story():
	dialogueText = currentStory.Continue()
	# # Create new dialogue panel
	var newDialoguePanel = dialoguePanel.instantiate() as InterfacePanel
	## Apply tags to current panel
	_handle_tags(currentStory.GetCurrentTags(), newDialoguePanel)

##  Displays the current line 
func _handle_panel_text(newDialoguePanel):
	##  Set anchor point
	newDialoguePanel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	dialoguePanels.push_front(newDialoguePanel)
	
	#  Ensures panels do not overflow
	if(dialoguePanels.size() > 3):
		_kill_panel(dialoguePanels[3])
		
	dialogueLabel = newDialoguePanel.find_child("Dialogue Text")
	add_child(newDialoguePanel)
	newDialoguePanel.showPanel()
	_animate_panels()
	_do_typewriter_text()
	
## Displays text incrementally with a typewriter effect and calls typewriter voice sounds (animalese)
func _do_typewriter_text():
	isTyping = true
	dialogueLabel.visible_characters = 0
	dialogueLabel.text = dialogueText
	var alphanumerics_count = 0 ## count of every non-punctuation character because those are the only characters we play animalese sounds for
	
	while dialogueLabel.visible_characters < dialogueText.length() - 1:
		var letter_index = dialogueLabel.visible_characters; 
		# TODO: currentSpeakerData.characterName always returns nil during testing. fix this
		var character_name = currentSpeakerData.characterName if (currentSpeakerData != null) else "Slip"
		
		var should_increment_alphanumeric_counter = $VoiceManager._handle_typewriter(
			dialogueText, character_name, letter_index, alphanumerics_count, textSpeedScale)
		
		dialogueLabel.visible_characters += 1
		if (should_increment_alphanumeric_counter): alphanumerics_count += 1
		
		await get_tree().create_timer(textSpeedInMilliseconds / textSpeedScale).timeout
	isTyping = false

## Move old panels
func _animate_panels():
	if(dialoguePanels.get(1)):
		awaitingAnimations = true
		var panelIndex = 1
		while panelIndex < dialoguePanels.size():
			var currentPanel = dialoguePanels[panelIndex]
			if(currentPanel.pivot_offset.x > 0 and panelIndex > 1):
				currentPanel.pivot_offset.x = currentPanel.size.x
			var xPos : float = currentPanel.position.x
			var yPos : float
			var newScale : Vector2
			if(panelIndex == 1):
				yPos = lowerDialogueBoxHeight
				newScale = lowerDialogueBoxScale
			else:
				yPos = upperDialogueBoxHeight
				newScale = upperDialogueBoxScale
			var heightTween = create_tween()
			heightTween.tween_property(currentPanel, "scale", newScale,1).set_trans(transitionType).set_ease(easeType)
			var positionTween = create_tween()
			positionTween.tween_property(currentPanel, "position", Vector2(xPos,yPos),1).set_trans(transitionType).set_ease(easeType)
			panelIndex += 1
			currentPanel.panel_texture.self_modulate = currentPanel.panel_texture.self_modulate.darkened(.2)
			#End animations
			if(panelIndex == dialoguePanels.size()):
				# FmodServer.play_one_shot("event:/SFX/UI/dialogue_appear")
				await positionTween.finished
				awaitingAnimations = false

func _kill_panel(panel : InterfacePanel):
	dialoguePanels.erase(panel)
	var t = create_tween()
	t.tween_property(panel, "scale", Vector2(0,0), 0.2)
	await(t.finished)
	panel.queue_free()

##Skips typing sequence
func _skip_scroll():
	dialogueLabel.visible_characters = dialogueText.length() - 1
	isTyping = false

##Reveals all initial interface panels
func _load_main_panels():
	for p in mainPanels:
		p.showPanel()

##Instances correct amount of choice boxes and gets choice index
func _display_choices():
	#Adjust portraits
	leftPortrait.self_modulate = Color.WHITE
	leftPortrait.scale = Vector2(1.2, 1.2)
	leftPortrait.material = portraitOutlineMaterial
	_draw_outline(leftPortrait.material)
	rightPortrait.self_modulate = previousSpeakerColor
	rightPortrait.scale = Vector2.ONE
	rightPortrait.material = null

	awaitingAnimations = true
	choicesDisplayed = true
	$"Choice Button Container".showPanel()
	dialoguePanels[0].hidePanel()
	var iter = 0
	
	for choice in currentStory.GetCurrentChoices():
		var newChoiceButton = choiceButton.instantiate() as DialogueChoiceButton
		newChoiceButton.panel_texture.texture = choice_button_sprites[iter]
		newChoiceButton.choiceText = choice.GetText()
		newChoiceButton.choiceIndex = iter
		$"Choice Button Container".add_child(newChoiceButton)
		if(iter == 0):
			newChoiceButton._highlight()
			selectedButton = newChoiceButton
		else:
			newChoiceButton._unhighlight()
		iter += 1
		
	await get_tree().create_timer(choiceSelectDelay).timeout
	awaitingAnimations = false

##Removes choice buttons
func _clear_choices():
	choicesDisplayed = false
	$"Choice Button Container".hidePanel()
	await get_tree().create_timer(1).timeout
	for c in $"Choice Button Container".get_children():
		c.queue_free()

##Returns choice box containing specified index
func _find_choice(desiredIndex):
	for c : DialogueChoiceButton in $"Choice Button Container".get_children():
		if c.choiceIndex == desiredIndex:
			return c

##Handles all Ink tag functions
func _handle_tags(currentTags, newPanel):
	if(currentTags.size() < 1):
		_reset_display()
	awaitingAnimations = true
	var differentSpeaker := false
	var changed_expression := false
	
	# print(currentTags)
	
	for t : String in currentTags:
		var splitTag = t.split(":")
		var tagKey = splitTag[0]
		var tagValue = splitTag[1]
		match(tagKey):
			"speaker":
				if(previousSpeakerTag != tagValue):
					differentSpeaker = true
					
				# # Get speaker data
				if(currentSpeakerData == null or currentSpeakerData.characterName != tagValue):
					# Load correct speaker data
					var resourcePath = "res://Assets/Dialogue/Character Dialogue Data/" + str(tagValue) + "DialogueData.tres"
					if ResourceLoader.exists(resourcePath):
						currentSpeakerData = load(resourcePath)
						
				##  Add character data attributes
				if(currentSpeakerData != null and currentSpeakerData.characterName == tagValue):
					newPanel.modulate = currentSpeakerData.colour
				else:
					print("[DIALOGUE] Could not get speaker data for: " + tagValue)
				
				## Check if Slip is the speaker
				if(tagValue == "Slip"):
					slipSpoke = true
					currentSpeaker = leftPortrait
					previousSpeaker = rightPortrait
				else:
					slipSpoke = false
					previousSpeaker = leftPortrait
					currentSpeaker = rightPortrait
					
					# Switches to new speaker
					if(lastNonSlipSpeaker != tagValue):
						var currentSpeakerPanel = currentSpeaker.get_parent()
						lastNonSlipSpeaker = tagValue
						var portraitPosition = currentSpeakerPanel.global_position
						var portraitTween = create_tween()
						portraitTween.tween_property(currentSpeakerPanel,"global_position", 
						portraitSwapPosition, portraitSwapTime/2).set_trans(transitionType).set_ease(easeType)
						await get_tree().create_timer(portraitSwapTime).timeout
						if(currentSpeakerData != null):
							currentSpeaker.texture = currentSpeakerData.default_portrait
						var portraitTween2 = create_tween()
						portraitTween2.tween_property(currentSpeakerPanel,"global_position", 
						portraitPosition, portraitSwapTime/2).set_trans(transitionType).set_ease(easeType)
						
					##Sets new panel to right side of screen
					if(tagValue != "None"):
						newPanel.pivot_offset = Vector2(dialoguePanels[0].size.x, 0)
						newPanel.panel_texture.texture = right_panel_sprite
						newPanel.set_to_right()
					
				## Adjust portraits based on speaker
				currentSpeaker.scale = speakingPortraitScale
				currentSpeaker.self_modulate = Color.WHITE
				previousSpeaker.scale = Vector2.ONE
				previousSpeaker.self_modulate = previousSpeakerColor
				previousSpeakerTag = tagValue
				
				# Portrait Outline
				if(differentSpeaker):
					previousSpeaker.material = null
					if(currentSpeaker.material == null):
						currentSpeaker.material = portraitOutlineMaterial
						_draw_outline(currentSpeaker.material)
						
			"expression":
				currentSpeaker.texture = (currentSpeakerData.expression_dictionary.get(tagValue, currentSpeaker.texture))
				changed_expression = true
			"anim":
				currentSpeaker.get_parent().find_child("Animator").play(tagValue)
			"bg":
				print("[DIALOGUE] Choosing new background!")
			"vo":
				if(tagValue == "play"):
					##TODO Play next voice line. If already playing a line, make sure to cut if off.
					$VoiceManager._handle_voiceover()
					pass
				else:
					##TODO Load based on tag value
					currentVOPath = tagValue
					print("[DIALOGUE] Loading VO files: ", currentVOPath)
			"fade":
				## Pauses dialogue and fades to black
				animator.play("fade")
				await animator.animation_finished
				
	## Return to default expression
	if(!changed_expression and currentSpeakerData != null):
		currentSpeaker.texture = currentSpeakerData.default_portrait
	awaitingAnimations = false
	_handle_panel_text(newPanel)

## Reset portrait attributes
func _reset_display():
	leftPortrait.scale = Vector2.ONE
	leftPortrait.self_modulate = Color.WHITE
	leftPortrait.material = null
	rightPortrait.scale = Vector2.ONE
	leftPortrait.self_modulate = Color.WHITE
	rightPortrait.material = null

func _hide_all_panels():
	for p in dialoguePanels:
		p.visible = false

func _draw_outline(drawMat : ShaderMaterial):
	var iter := 1.0
	while iter > 0:
		drawMat.set_shader_parameter("threshold", iter)
		if(sketchyDraw):
			drawMat.set_shader_parameter("dist", randi_range(outlineSize - 3, outlineSize + 3))
		iter -= 0.1
		await get_tree().create_timer(0.03).timeout
	drawMat.set_shader_parameter("dist", outlineSize)
	return
