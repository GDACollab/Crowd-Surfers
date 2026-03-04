extends Control
class_name DialogueInterface

@export var mainPanels : Array[InterfacePanel]
##Dialogue Panel prefab
@export var dialoguePanel : PackedScene
##Type of transition for all tweens
@export var transitionType : Tween.TransitionType = Tween.TransitionType.TRANS_ELASTIC
@export var easeType : Tween.EaseType = Tween.EaseType.EASE_IN_OUT
@export_category("Choices")
##Choice Button prefab
@export var choiceButton : PackedScene
##Amount of time the player must wait before selecing a choice
@export var choiceSelectDelay : float
@export_category("Portrait Settings")
@export var defaultPortait : Texture2D
@export var speakingPortraitScale := Vector2(1.25, 1.25)
@export var previousSpeakerColor := Color.DIM_GRAY
##Where the portrait moves when swapping characters
@export var portraitSwapPosition := Vector2(2000, 345)
@export var portraitSwapTime := 1.0
@export_category("Past Dialogue Line Settings")
@export var upperDialogueBoxHeight : float = 0
@export var upperDialogueBoxScale := Vector2(0.5, 0.5)
@export var lowerDialogueBoxHeight : float = 200
@export var lowerDialogueBoxScale := Vector2(0.75, 0.75)
@onready var leftPortrait = $"Left Character Portrait/Portrait Image"
@onready var rightPortrait = $"Right Character Portrait/Portrait Image"
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
var previousSpeaker : Control
var lastNonSlipSpeaker : String = ""
var awaitingAnimations := false
var awaitingTags := false

func _ready() -> void:
	currentStory = Inky.GetCurrentStory()
	$"Left Character Portrait".find_child("Portrait Image").texture = defaultPortait
	_load_main_panels()
	_get_input()

func _process(_delta: float) -> void:
	if(Input.is_action_just_pressed("DialogueInteract")):
		if(!isTyping):
			_get_input()
		else:
			_skip_scroll()
	#Choice selection
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
		#Continue story
		if(currentStory.GetCanContinue()):
			_continue_story()
		#Display choices
		elif(currentStory.GetCurrentChoices().size() > 0 and !choicesDisplayed):
			_display_choices()
		#Make choice
		elif(currentStory.GetCurrentChoices().size() > 0 and choicesDisplayed):
			currentStory.ChooseChoiceIndex(currentChoiceIndex)
			_clear_choices()
			_continue_story()
		#End story
		else:
			Inky.EndDialogue()

##Loads next line
func _continue_story():
	dialogueText = currentStory.Continue()
	#Spawn new dialogue panel
	var newDialoguePanel = dialoguePanel.instantiate() as InterfacePanel
	_handle_tags(currentStory.GetCurrentTags(), newDialoguePanel)

##Displays the current line incrementaly
func _display_text(newDialoguePanel):
	#Set anchor point
	newDialoguePanel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	dialoguePanels.push_front(newDialoguePanel)
	#Ensures panels do not overflow
	if(dialoguePanels.size() > 3):
		_kill_panel(dialoguePanels[3])
	dialogueLabel = newDialoguePanel.find_child("Dialogue Text")
	add_child(newDialoguePanel)
	newDialoguePanel.showPanel()
	_animate_panels()
	
	isTyping = true
	dialogueLabel.visible_characters = 0
	dialogueLabel.text = dialogueText
	while dialogueLabel.visible_characters < dialogueText.length() - 1:
		dialogueLabel.visible_characters += 1
		await get_tree().create_timer(0.05).timeout
	isTyping = false

##Move old panels
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
			#End animations
			if(panelIndex == dialoguePanels.size()):
				await positionTween.finished
				awaitingAnimations = false

func _kill_panel(panel : InterfacePanel):
	dialoguePanels.remove_at(3)
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
	rightPortrait.self_modulate = previousSpeakerColor
	rightPortrait.scale = Vector2.ONE

	awaitingAnimations = true
	choicesDisplayed = true
	$"Choice Button Container".showPanel()
	dialoguePanels[0].hidePanel()
	var iter = 0
	for choice in currentStory.GetCurrentChoices():
		var newChoiceButton = choiceButton.instantiate() as DialogueChoiceButton
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
	_reset_display()
	awaitingAnimations = true
	for t : String in currentTags:
		var splitTag = t.split(":")
		var tagKey = splitTag[0]
		var tagValue = splitTag[1]
		match(tagKey):
			"speaker":
				#Get speaker data
				if(currentSpeakerData == null or currentSpeakerData.characterName != tagValue):
					#Load correct speaker data
					var resourcePath = "res://Assets/Dialogue/Character Dialogue Data/" + str(tagValue) + "DialogueData.tres"
					if ResourceLoader.exists(resourcePath):
						currentSpeakerData = load(resourcePath)
						print("Loaded speaker data")
				#Add character data attributes
				if(currentSpeakerData != null and currentSpeakerData.characterName == tagValue):
					newPanel.modulate = currentSpeakerData.colour
				else:
					print("Could not get speaker data for: " + tagValue)
				if(tagValue == "Slip"):
					slipSpoke = true
					currentSpeaker = leftPortrait
					previousSpeaker = rightPortrait
				else:
					slipSpoke = false
					previousSpeaker = leftPortrait
					currentSpeaker = rightPortrait
					#Switches to new speaker
					if(lastNonSlipSpeaker != tagValue):
						var currentSpeakerPanel = currentSpeaker.get_parent()
						print("New speaker detected!")
						lastNonSlipSpeaker = tagValue
						var portraitPosition = currentSpeakerPanel.global_position
						var portraitTween = create_tween()
						portraitTween.tween_property(currentSpeakerPanel,"global_position", 
						portraitSwapPosition, portraitSwapTime/2).set_trans(transitionType).set_ease(easeType)
						await get_tree().create_timer(portraitSwapTime).timeout
						if(currentSpeakerData != null and currentSpeakerData.portraits.size() > 0):
							currentSpeaker.texture = currentSpeakerData.portraits[0]
						var portraitTween2 = create_tween()
						portraitTween2.tween_property(currentSpeakerPanel,"global_position", 
						portraitPosition, portraitSwapTime/2).set_trans(transitionType).set_ease(easeType)
					#Sets new panel to right side of screen
					newPanel.pivot_offset = Vector2(dialoguePanels[0].size.x, 0)
				#Adjust portraits based on speaker
				currentSpeaker.scale = speakingPortraitScale
				currentSpeaker.self_modulate = Color.WHITE
				previousSpeaker.scale = Vector2.ONE
				previousSpeaker.self_modulate = previousSpeakerColor
			"expression":
				pass
			"anim":
				currentSpeaker.get_parent().find_child("Animator").play(tagValue)
			"bg":
				print("Choosing new background!")
	awaitingAnimations = false
	_display_text(newPanel)

func _reset_display():
	leftPortrait.scale = Vector2.ONE
	leftPortrait.self_modulate = Color.WHITE
	rightPortrait.scale = Vector2.ONE
	leftPortrait.self_modulate = Color.WHITE
