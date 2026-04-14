extends Node2D

@export var story : InkStory
@export var knot : String
## Scene to transition to after this dialogue has finished
@export var nextScenePath : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#This is all you need to do in order to play dialogue! Swag!
	Inky.SetNewStory(story)
	Inky.PlayStoryFromKnot(knot)
	Inky.DialogueEnded.connect(_on_dialogue_end)

func _on_dialogue_end():
	if(nextScenePath):
		SceneFadeTransition.transition_to_scene_with_loading(nextScenePath)
