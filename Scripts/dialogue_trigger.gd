extends Node2D

@export var story : InkStory
@export var knot : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#This is all you need to do in order to play dialogue! Swag!
	Inky.SetNewStory(story)
	Inky.PlayStoryFromKnot(knot)
