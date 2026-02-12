extends Control
class_name DialogueInterface

@export var mainPanels : Array[InterfacePanel]
@export var dialogueLabel : Label
@export var choiceButton : PackedScene
var currentStory : InkStory
var currentChoiceIndex := 1
var isTyping := false
var dialogueText := ""
var choiceButtons : Array[Control]
var choicesDisplayed := false
var slipSpoke := false ##If true, last dialogue box goes left

func _ready() -> void:
	currentStory = Inky.GetCurrentStory()
	_load_main_panels()
	_continue_story()
	
func _process(_delta: float) -> void:
	if(Input.is_action_just_pressed("DialogueInteract")):
		if(choicesDisplayed):
			_clear_choices()
		if(!isTyping):
			_continue_story()
		else:
			_skip_scroll()

func _continue_story():
	#Continue story
	if(currentStory.GetCanContinue()):
		dialogueText = currentStory.Continue()
		_display_text()
		_handle_tags(currentStory.GetCurrentTags())
	#Get choices
	elif(currentStory.GetCurrentChoices().size() > 0):
			_display_choices()
			currentStory.ChooseChoiceIndex(currentChoiceIndex)
	#End dialogue
	else:
		Inky.EndDialogue()

##Displays the current line incrementaly
func _display_text():
	isTyping = true
	dialogueLabel.visible_characters = 0
	dialogueLabel.text = dialogueText
	while dialogueLabel.visible_characters < dialogueText.length():
		dialogueLabel.visible_characters += 1
		await get_tree().create_timer(0.05).timeout
	isTyping = false

##Skips typing sequence
func _skip_scroll():
	dialogueLabel.visible_characters = dialogueText.length()
	isTyping = false

func _load_main_panels():
	for p in mainPanels:
		p.showPanel()

##Instances correct amount of choice boxes and gets choice index
func _display_choices():
	choicesDisplayed = true
	for choice in currentStory.GetCurrentChoices():
		var newChoiceButton = choiceButton.instantiate() as DialogueChoiceButton
		newChoiceButton.choiceText = choice.GetText()
		$"Choice Button Container".add_child(newChoiceButton)

##Removes choice buttons
func _clear_choices():
	pass
	for c in $"Choice Button Container".get_children():
		c.queue_free()
	choicesDisplayed = false

func _handle_tags(currentTags):
	for t in currentTags:
		print(t)
